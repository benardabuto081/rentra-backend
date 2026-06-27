import { Controller, Post, Body, UseGuards, Req } from '@nestjs/common';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './jwt.guard';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  // POST /auth/register
  @Post('register')
  async register(
    @Body()
    body: {
      firstName: string;
      lastName: string;
      email: string;
      password: string;
    },
  ) {
    return this.authService.registerLandlord(body);
  }

  // POST /auth/otp/send
  @Post('otp/send')
  async sendOtp(
    @Body() body: { recipient: string; type: 'phone' | 'email' },
  ) {
    return this.authService.sendOtp(body.recipient, body.type);
  }

  // POST /auth/otp/verify
  @Post('otp/verify')
  async verifyOtp(
    @Body() body: { recipient: string; type: 'phone' | 'email'; code: string },
  ) {
    return this.authService.verifyOtp(body.recipient, body.type, body.code);
  }

  // POST /auth/register-tenant
  @Post('register-tenant')
  async registerTenant(
    @Body()
    body: {
      firstName: string;
      lastName: string;
      phone: string;
      email?: string;
      password: string;
    },
  ) {
    return this.authService.registerIndependentTenant(body);
  }

  // POST /auth/login
  @Post('login')
  async login(
    @Body()
    body: {
      email: string;
      password: string;
    },
  ) {
    return this.authService.login(body);
  }

  // POST /auth/link-passkey
  @UseGuards(JwtAuthGuard)
  @Post('link-passkey')
  async linkPasskey(
    @Req() req: any,
    @Body()
    body: {
      passkeyCode: string;
      rentAmount: number;
      storageAmount?: number;
      depositAmount?: number;
      moveInDate: string;
    },
  ) {
    return this.authService.linkPasskeyToTenant({
      tenantUserId: req.user.userId,
      passkeyCode: body.passkeyCode.trim().toUpperCase(),
      rentAmount: body.rentAmount,
      storageAmount: body.storageAmount,
      depositAmount: body.depositAmount,
      moveInDate: new Date(body.moveInDate),
    });
  }

  // POST /auth/tenant-login
  @Post('tenant-login')
  async tenantLogin(
    @Body()
    body: {
      phone: string;
      password: string;
    },
  ) {
    return this.authService.tenantLogin(body);
  }

  // POST /auth/generate-passkey
  @Post('generate-passkey')
  async generatePasskey(
    @Body()
    body: {
      unitId: string;
      organizationId: string;
      generatedBy: string;
      expiresInDays?: number;
    },
  ) {
    return this.authService.generatePasskey(body);
  }

  // POST /auth/onboard-tenant
  @Post('onboard-tenant')
  async onboardTenant(
    @Body()
    body: {
      passkeyCode: string;
      firstName: string;
      lastName: string;
      phone: string;
      email?: string;
      password: string;
    },
  ) {
    return this.authService.onboardTenant(body);
  }
}