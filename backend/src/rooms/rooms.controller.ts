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
import { RoomsService } from './rooms.service';
import { RoomType } from './room.entity';

@UseGuards(JwtAuthGuard)
@Controller('organizations/:organizationId/buildings/:buildingId/rooms')
export class RoomsController {
  constructor(private roomsService: RoomsService) {}

  @Post()
  async create(
    @Param('organizationId') organizationId: string,
    @Param('buildingId') buildingId: string,
    @Body()
    body: {
      name: string;
      floor?: number;
      type?: RoomType;
      rentAmount: number;
      storageAmount?: number;
      description?: string;
    },
  ) {
    return this.roomsService.create({ ...body, buildingId, organizationId });
  }

  @Get()
  async findAll(
    @Param('organizationId') organizationId: string,
    @Param('buildingId') buildingId: string,
  ) {
    return this.roomsService.findAll(buildingId, organizationId);
  }

  @Get('vacant')
  async findVacant(
    @Param('organizationId') organizationId: string,
    @Param('buildingId') buildingId: string,
  ) {
    return this.roomsService.findVacant(buildingId, organizationId);
  }

  @Get(':id')
  async findOne(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
  ) {
    return this.roomsService.findById(id, organizationId);
  }

  @Patch(':id')
  async update(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
    @Body()
    body: Partial<{
      name: string;
      floor: number;
      type: RoomType;
      rentAmount: number;
      storageAmount: number;
      description: string;
    }>,
  ) {
    return this.roomsService.update(id, organizationId, body);
  }

  @Patch(':id/vacate')
  async vacate(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
  ) {
    return this.roomsService.vacateRoom(id, organizationId);
  }
}