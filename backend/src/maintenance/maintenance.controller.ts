import {
  Controller,
  Post,
  Get,
  Patch,
  Body,
  Param,
} from '@nestjs/common';
import { MaintenanceService } from './maintenance.service';
import { MaintenanceCategory, MaintenancePriority } from './maintenance.entity';

@Controller('organizations/:organizationId/maintenance')
export class MaintenanceController {
  constructor(private maintenanceService: MaintenanceService) {}

  // POST /organizations/:organizationId/maintenance
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

  // GET /organizations/:organizationId/maintenance
  @Get()
  async findAll(@Param('organizationId') organizationId: string) {
    return this.maintenanceService.findAll(organizationId);
  }

  // GET /organizations/:organizationId/maintenance/pending
  @Get('pending')
  async findPending(@Param('organizationId') organizationId: string) {
    return this.maintenanceService.findPending(organizationId);
  }

  // GET /organizations/:organizationId/maintenance/tenant/:tenantId
  @Get('tenant/:tenantId')
  async findByTenant(
    @Param('organizationId') organizationId: string,
    @Param('tenantId') tenantId: string,
  ) {
    return this.maintenanceService.findByTenant(tenantId, organizationId);
  }

  // GET /organizations/:organizationId/maintenance/:id
  @Get(':id')
  async findOne(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
  ) {
    return this.maintenanceService.findById(id, organizationId);
  }

  // PATCH /organizations/:organizationId/maintenance/:id/assign
  @Patch(':id/assign')
  async assign(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
    @Body() body: { assignedTo: string },
  ) {
    return this.maintenanceService.assign(id, organizationId, body.assignedTo);
  }

  // PATCH /organizations/:organizationId/maintenance/:id/resolve
  @Patch(':id/resolve')
  async resolve(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
    @Body() body: { resolutionNotes: string; cost?: number },
  ) {
    return this.maintenanceService.resolve(id, organizationId, body);
  }

  // PATCH /organizations/:organizationId/maintenance/:id/cancel
  @Patch(':id/cancel')
  async cancel(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
  ) {
    return this.maintenanceService.cancel(id, organizationId);
  }

  // PATCH /organizations/:organizationId/maintenance/:id/priority
  @Patch(':id/priority')
  async updatePriority(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
    @Body() body: { priority: MaintenancePriority },
  ) {
    return this.maintenanceService.updatePriority(id, organizationId, body.priority);
  }
}