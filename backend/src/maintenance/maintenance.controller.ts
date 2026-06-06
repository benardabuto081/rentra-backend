import {
  Controller,
  Post,
  Get,
  Patch,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { MaintenanceService } from './maintenance.service';
import { MaintenanceCategory, MaintenancePriority } from './maintenance.entity';

@UseGuards(JwtAuthGuard)
@Controller('organizations/:organizationId/maintenance')
export class MaintenanceController {
  constructor(private maintenanceService: MaintenanceService) {}

  @Post()
  async create(
    @Param('organizationId') organizationId: string,
    @Body()
    body: {
      buildingId: string;
      roomId: string;
      tenantId: string;
      title: string;
      description: string;
      category?: MaintenanceCategory;
      priority?: MaintenancePriority;
    },
  ) {
    return this.maintenanceService.create({ ...body, organizationId });
  }

  @Get()
  async findAll(@Param('organizationId') organizationId: string) {
    return this.maintenanceService.findAll(organizationId);
  }

  @Get('pending')
  async findPending(@Param('organizationId') organizationId: string) {
    return this.maintenanceService.findPending(organizationId);
  }

  @Get('tenant/:tenantId')
  async findByTenant(
    @Param('organizationId') organizationId: string,
    @Param('tenantId') tenantId: string,
  ) {
    return this.maintenanceService.findByTenant(tenantId, organizationId);
  }

  @Get(':id')
  async findOne(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
  ) {
    return this.maintenanceService.findById(id, organizationId);
  }

  @Patch(':id/assign')
  async assign(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
    @Body() body: { assignedTo: string },
  ) {
    return this.maintenanceService.assign(id, organizationId, body.assignedTo);
  }

  @Patch(':id/resolve')
  async resolve(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
    @Body() body: { resolutionNotes: string; cost?: number },
  ) {
    return this.maintenanceService.resolve(id, organizationId, body);
  }

  @Patch(':id/cancel')
  async cancel(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
  ) {
    return this.maintenanceService.cancel(id, organizationId);
  }

  @Patch(':id/priority')
  async updatePriority(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
    @Body() body: { priority: MaintenancePriority },
  ) {
    return this.maintenanceService.updatePriority(id, organizationId, body.priority);
  }
}