import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Tenant, TenantStatus } from './tenant.entity';
import { RoomsService } from '../rooms/rooms.service';

@Injectable()
export class TenantsService {
  constructor(
    @InjectRepository(Tenant)
    private tenantsRepository: Repository<Tenant>,
    private roomsService: RoomsService,
  ) {}

   async create(data: {
    userId: string;
    roomId: string;
    buildingId: string;
    organizationId: string;
    rentAmount: number;
    storageAmount?: number;
    depositAmount?: number;
    moveInDate: Date;
    notes?: string;
  }): Promise<Tenant> {
    const existing = await this.tenantsRepository.findOne({
      where: {
        roomId: data.roomId,
        status: TenantStatus.ACTIVE,
      },
    });
    if (existing) {
      throw new BadRequestException('Room already has an active tenant');
    }
    const tenant = this.tenantsRepository.create({
      ...data,
      status: TenantStatus.ACTIVE,
    });
    const savedTenant = await this.tenantsRepository.save(tenant);

    // Auto-update room status to occupied
    await this.roomsService.assignTenant(
      data.roomId,
      data.organizationId,
      savedTenant.id,
    );

    return savedTenant;
  }

  async findAll(organizationId: string): Promise<Tenant[]> {
    return this.tenantsRepository.find({
      where: { organizationId },
      order: { createdAt: 'DESC' },
    });
  }

  async findActive(organizationId: string): Promise<Tenant[]> {
    return this.tenantsRepository.find({
      where: { organizationId, status: TenantStatus.ACTIVE },
    });
  }

  async findByRoom(roomId: string): Promise<Tenant | null> {
    return this.tenantsRepository.findOne({
      where: { roomId, status: TenantStatus.ACTIVE },
    });
  }

  async findByUser(userId: string, organizationId: string): Promise<Tenant[]> {
    return this.tenantsRepository.find({
      where: { userId, organizationId },
    });
  }

  async findById(id: string, organizationId: string): Promise<Tenant> {
    const tenant = await this.tenantsRepository.findOne({
      where: { id, organizationId },
    });
    if (!tenant) {
      throw new NotFoundException('Tenant not found');
    }
    return tenant;
  }

  async giveNotice(id: string, organizationId: string, noticeDate: Date): Promise<Tenant> {
    const tenant = await this.findById(id, organizationId);
    if (tenant.status !== TenantStatus.ACTIVE) {
      throw new BadRequestException('Tenant is not active');
    }
    await this.tenantsRepository.update(id, {
      status: TenantStatus.NOTICE,
      noticeDate,
    });
    return this.findById(id, organizationId);
  }

  async vacate(id: string, organizationId: string, moveOutDate: Date): Promise<Tenant> {
    const tenant = await this.findById(id, organizationId);
    if (tenant.status === TenantStatus.VACATED) {
      throw new BadRequestException('Tenant has already vacated');
    }
    await this.tenantsRepository.update(id, {
      status: TenantStatus.VACATED,
      moveOutDate,
    });

    // Auto-update room status to vacant
    await this.roomsService.vacateRoom(tenant.roomId, organizationId);

    return this.findById(id, organizationId);
  }

  async update(id: string, organizationId: string, data: Partial<Tenant>): Promise<Tenant> {
    await this.findById(id, organizationId);
    await this.tenantsRepository.update(id, data);
    return this.findById(id, organizationId);
  }
}