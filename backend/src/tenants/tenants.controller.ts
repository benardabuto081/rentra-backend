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
import { TenantsService } from './tenants.service';

@UseGuards(JwtAuthGuard)
@Controller('organizations/:organizationId/tenants')
export class TenantsController {
  constructor(private tenantsService: TenantsService) {}

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

  @Get()
  async findAll(@Param('organizationId') organizationId: string) {
    return this.tenantsService.findAll(organizationId);
  }

  @Get('active')
  async findActive(@Param('organizationId') organizationId: string) {
    return this.tenantsService.findActive(organizationId);
  }

  @Get(':id')
  async findOne(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
  ) {
    return this.tenantsService.findById(id, organizationId);
  }

  @Patch(':id/notice')
  async giveNotice(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
    @Body() body: { noticeDate: Date },
  ) {
    return this.tenantsService.giveNotice(id, organizationId, body.noticeDate);
  }

  @Patch(':id/vacate')
  async vacate(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
    @Body() body: { moveOutDate: Date },
  ) {
    return this.tenantsService.vacate(id, organizationId, body.moveOutDate);
  }

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