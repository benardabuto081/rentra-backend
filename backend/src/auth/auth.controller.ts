import { Controller, Post, Body } from '@nestjs/common';
import { AuthService } from './auth.service';

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