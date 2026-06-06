import {
  Controller,
  Post,
  Get,
  Patch,
  Body,
  Param,
} from '@nestjs/common';
import { TenantsService } from './tenants.service';

@Controller('organizations/:organizationId/tenants')
export class TenantsController {
  constructor(private tenantsService: TenantsService) {}

  // POST /organizations/:organizationId/tenants
  @Post()
  async create(
    @Param('organizationId') organizationId: string,
    @Body()
    body: {
      userId: string;
      roomId: string;
      buildingId: string;
      rentAmount: number;
      storageAmount?: number;
      depositAmount?: number;
      moveInDate: Date;
      notes?: string;
    },
  ) {
    return this.tenantsService.create({ ...body, organizationId });
  }

  // GET /organizations/:organizationId/tenants
  @Get()
  async findAll(@Param('organizationId') organizationId: string) {
    return this.tenantsService.findAll(organizationId);
  }

  // GET /organizations/:organizationId/tenants/active
  @Get('active')
  async findActive(@Param('organizationId') organizationId: string) {
    return this.tenantsService.findActive(organizationId);
  }

  // GET /organizations/:organizationId/tenants/:id
  @Get(':id')
  async findOne(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
  ) {
    return this.tenantsService.findById(id, organizationId);
  }

  // PATCH /organizations/:organizationId/tenants/:id/notice
  @Patch(':id/notice')
  async giveNotice(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
    @Body() body: { noticeDate: Date },
  ) {
    return this.tenantsService.giveNotice(id, organizationId, body.noticeDate);
  }

  // PATCH /organizations/:organizationId/tenants/:id/vacate
  @Patch(':id/vacate')
  async vacate(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
    @Body() body: { moveOutDate: Date },
  ) {
    return this.tenantsService.vacate(id, organizationId, body.moveOutDate);
  }

  // PATCH /organizations/:organizationId/tenants/:id
  @Patch(':id')
  async update(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
    @Body() body: Partial<{
      rentAmount: number;
      storageAmount: number;
      notes: string;
    }>,
  ) {
    return this.tenantsService.update(id, organizationId, body);
  }
}
