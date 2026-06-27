import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Passkey, PasskeyStatus } from './passkey.entity';
import { UsersService } from '../users/users.service';
import { UserRole } from '../users/user.entity';
import * as crypto from 'crypto';
import { OrganizationsService } from '../organizations/organizations.service';
import { TenantsService } from '../tenants/tenants.service';
import { RoomsService } from '../rooms/rooms.service';
import { OtpService } from '../otp/otp.service';
import { OtpType } from '../otp/otp.entity';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(Passkey)
    private passkeyRepository: Repository<Passkey>,
    private usersService: UsersService,
    private jwtService: JwtService,
    private organizationsService: OrganizationsService,
    private tenantsService: TenantsService,
    private roomsService: RoomsService,
    private otpService: OtpService,
  ) {}

  async sendOtp(recipient: string, type: 'phone' | 'email') {
    const otpType = type === 'phone' ? OtpType.PHONE : OtpType.EMAIL;
    return this.otpService.sendOtp(recipient, otpType);
  }

  async verifyOtp(recipient: string, type: 'phone' | 'email', code: string) {
    const otpType = type === 'phone' ? OtpType.PHONE : OtpType.EMAIL;
    return this.otpService.verifyOtp(recipient, otpType, code);
  }

  // LANDLORD REGISTRATION
  async registerLandlord(data: {
    firstName: string;
    lastName: string;
    email: string;
    password: string;
  }) {
    const existing = await this.usersService.findByEmail(data.email);
    if (existing) {
      throw new BadRequestException('Email already registered');
    }

    const user = await this.usersService.createLandlord(data);

    const organization = await this.organizationsService.create({
      name: `${data.firstName}'s Organization`,
      ownerId: user.id,
      email: data.email,
    });

    await this.usersService.updateOrganization(user.id, organization.id);

    const updatedUser = await this.usersService.findById(user.id);

    const token = this.generateToken(user.id, user.role);
    return { user: updatedUser, organization, token };
  }

  // LANDLORD / CARETAKER LOGIN
  async login(data: { email: string; password: string }) {
    const user = await this.usersService.findByEmail(data.email);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }
    const valid = await this.usersService.validatePassword(
      data.password,
      user.password,
    );
    if (!valid) {
      throw new UnauthorizedException('Invalid credentials');
    }
    const token = this.generateToken(user.id, user.role);
    return { user, token };
  }

  // GENERATE PASSKEY FOR A UNIT
  async generatePasskey(data: {
    unitId: string;
    organizationId: string;
    generatedBy: string;
    expiresInDays?: number;
  }): Promise<Passkey> {
    await this.passkeyRepository.update(
      { unitId: data.unitId, status: PasskeyStatus.ACTIVE },
      { status: PasskeyStatus.REVOKED },
    );

    const code = this.generatePasskeyCode();
    const expiresAt = data.expiresInDays
      ? new Date(Date.now() + data.expiresInDays * 24 * 60 * 60 * 1000)
      : null;

    const passkey = new Passkey();
    passkey.code = code;
    passkey.unitId = data.unitId;
    passkey.organizationId = data.organizationId;
    passkey.generatedBy = data.generatedBy;
    passkey.expiresAt = expiresAt;
    passkey.status = PasskeyStatus.ACTIVE;

    return this.passkeyRepository.save(passkey);
  }

  // INDEPENDENT TENANT REGISTRATION (no landlord/org required)
  async registerIndependentTenant(data: {
    firstName: string;
    lastName: string;
    phone: string;
    email?: string;
    password: string;
  }) {
    const existing = await this.usersService.findByPhone(data.phone);
    if (existing) {
      throw new BadRequestException('Phone number already registered');
    }
    if (data.email) {
      const existingEmail = await this.usersService.findByEmail(data.email);
      if (existingEmail) {
        throw new BadRequestException('Email already registered');
      }
    }

    const tenant = await this.usersService.createTenant({
      firstName: data.firstName,
      lastName: data.lastName,
      phone: data.phone,
      email: data.email,
      password: data.password,
      organizationId: undefined,
    });

    const token = this.generateToken(tenant.id, UserRole.TENANT);
    return { user: tenant, token };
  }

  // LINK PASSKEY TO AN ALREADY-REGISTERED TENANT (independent -> managed)
  async linkPasskeyToTenant(data: {
    tenantUserId: string;
    passkeyCode: string;
    rentAmount: number;
    storageAmount?: number;
    depositAmount?: number;
    moveInDate: Date;
  }) {
    const passkey = await this.passkeyRepository.findOne({
      where: { code: data.passkeyCode },
    });

    if (!passkey) {
      throw new NotFoundException('Invalid passkey');
    }
    if (passkey.status !== PasskeyStatus.ACTIVE) {
      throw new BadRequestException('Passkey has already been used or revoked');
    }
    if (passkey.expiresAt && passkey.expiresAt < new Date()) {
      throw new BadRequestException('Passkey has expired');
    }

    const tenantUser = await this.usersService.findById(data.tenantUserId);
    if (!tenantUser) {
      throw new NotFoundException('Tenant account not found');
    }

    const room = await this.roomsService.findById(
      passkey.unitId,
      passkey.organizationId,
    );

    await this.usersService.updateOrganization(
      tenantUser.id,
      passkey.organizationId,
    );

    const tenantRecord = await this.tenantsService.create({
      userId: tenantUser.id,
      roomId: passkey.unitId,
      buildingId: room.buildingId,
      organizationId: passkey.organizationId,
      rentAmount: data.rentAmount,
      storageAmount: data.storageAmount,
      depositAmount: data.depositAmount,
      moveInDate: data.moveInDate,
    });

    await this.passkeyRepository.update(passkey.id, {
      status: PasskeyStatus.USED,
      usedBy: tenantUser.id,
      usedAt: new Date(),
    });

    const updatedUser = await this.usersService.findById(tenantUser.id);
    const token = this.generateToken(tenantUser.id, UserRole.TENANT);

    return { user: updatedUser, tenant: tenantRecord, token };
  }

  // TENANT ONBOARDING WITH PASSKEY
  async onboardTenant(data: {
    passkeyCode: string;
    firstName: string;
    lastName: string;
    phone: string;
    email?: string;
    password: string;
  }) {
    const passkey = await this.passkeyRepository.findOne({
      where: { code: data.passkeyCode },
    });

    if (!passkey) {
      throw new NotFoundException('Invalid passkey');
    }
    if (passkey.status !== PasskeyStatus.ACTIVE) {
      throw new BadRequestException('Passkey has already been used or revoked');
    }
    if (passkey.expiresAt && passkey.expiresAt < new Date()) {
      throw new BadRequestException('Passkey has expired');
    }

    const tenant = await this.usersService.createTenant({
      firstName: data.firstName,
      lastName: data.lastName,
      phone: data.phone,
      email: data.email,
      password: data.password,
      organizationId: passkey.organizationId,
    });

    await this.passkeyRepository.update(passkey.id, {
      status: PasskeyStatus.USED,
      usedBy: tenant.id,
      usedAt: new Date(),
    });

    const token = this.generateToken(tenant.id, UserRole.TENANT);
    return { user: tenant, token };
  }

  // TENANT LOGIN
  async tenantLogin(data: { phone: string; password: string }) {
    const user = await this.usersService.findByPhone(data.phone);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }
    const valid = await this.usersService.validatePassword(
      data.password,
      user.password,
    );
    if (!valid) {
      throw new UnauthorizedException('Invalid credentials');
    }
    const token = this.generateToken(user.id, user.role);
    return { user, token };
  }

  private generateToken(userId: string, role: string): string {
    return this.jwtService.sign({ sub: userId, role });
  }

  private generatePasskeyCode(): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const random = crypto.randomBytes(6);
    let code = 'RTR-';
    for (let i = 0; i < 6; i++) {
      code += chars[random[i] % chars.length];
    }
    return code;
  }
}