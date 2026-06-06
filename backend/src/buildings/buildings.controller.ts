import {
  Controller,
  Post,
  Get,
  Patch,
  Delete,
  Body,
  Param,
} from '@nestjs/common';
import { BuildingsService } from './buildings.service';

@Controller('organizations/:organizationId/buildings')
export class BuildingsController {
  constructor(private buildingsService: BuildingsService) {}

  // POST /organizations/:organizationId/buildings
  @Post()
  async create(
    @Param('organizationId') organizationId: string,
    @Body()
    body: {
      name: string;
      address?: string;
      city?: string;
      county?: string;
      totalFloors?: number;
      description?: string;
    },
  ) {
    return this.buildingsService.create({ ...body, organizationId });
  }

  // GET /organizations/:organizationId/buildings
  @Get()
  async findAll(@Param('organizationId') organizationId: string) {
    return this.buildingsService.findAll(organizationId);
  }

  // GET /organizations/:organizationId/buildings/:id
  @Get(':id')
  async findOne(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
  ) {
    return this.buildingsService.findById(id, organizationId);
  }

  // PATCH /organizations/:organizationId/buildings/:id
  @Patch(':id')
  async update(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
    @Body()
    body: Partial<{
      name: string;
      address: string;
      city: string;
      county: string;
      totalFloors: number;
      description: string;
    }>,
  ) {
    return this.buildingsService.update(id, organizationId, body);
  }

  // DELETE /organizations/:organizationId/buildings/:id
  @Delete(':id')
  async deactivate(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
  ) {
    return this.buildingsService.deactivate(id, organizationId);
  }
}