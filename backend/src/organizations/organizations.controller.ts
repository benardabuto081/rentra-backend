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
import { OrganizationsService } from './organizations.service';

@UseGuards(JwtAuthGuard)
@Controller('organizations')
export class OrganizationsController {
  constructor(private organizationsService: OrganizationsService) {}

  @Post()
  async create(
    @Body()
    body: {
      name: string;
      ownerId: string;
      phone?: string;
      email?: string;
      address?: string;
      city?: string;
    },
  ) {
    return this.organizationsService.create(body);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.organizationsService.findById(id);
  }

  @Get('owner/:ownerId')
  async findByOwner(@Param('ownerId') ownerId: string) {
    return this.organizationsService.findByOwner(ownerId);
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body()
    body: Partial<{
      name: string;
      phone: string;
      email: string;
      address: string;
      city: string;
    }>,
  ) {
    return this.organizationsService.update(id, body);
  }
}
