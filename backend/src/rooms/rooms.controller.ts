import {
  Controller,
  Post,
  Get,
  Patch,
  Body,
  Param,
} from '@nestjs/common';
import { RoomsService } from './rooms.service';
import { RoomType } from './room.entity';

@Controller('organizations/:organizationId/buildings/:buildingId/rooms')
export class RoomsController {
  constructor(private roomsService: RoomsService) {}

  // POST /organizations/:organizationId/buildings/:buildingId/rooms
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

  // GET /organizations/:organizationId/buildings/:buildingId/rooms
  @Get()
  async findAll(
    @Param('organizationId') organizationId: string,
    @Param('buildingId') buildingId: string,
  ) {
    return this.roomsService.findAll(buildingId, organizationId);
  }

  // GET /organizations/:organizationId/buildings/:buildingId/rooms/vacant
  @Get('vacant')
  async findVacant(
    @Param('organizationId') organizationId: string,
    @Param('buildingId') buildingId: string,
  ) {
    return this.roomsService.findVacant(buildingId, organizationId);
  }

  // GET /organizations/:organizationId/buildings/:buildingId/rooms/:id
  @Get(':id')
  async findOne(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
  ) {
    return this.roomsService.findById(id, organizationId);
  }

  // PATCH /organizations/:organizationId/buildings/:buildingId/rooms/:id
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

  // PATCH /organizations/:organizationId/buildings/:buildingId/rooms/:id/vacate
  @Patch(':id/vacate')
  async vacate(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
  ) {
    return this.roomsService.vacateRoom(id, organizationId);
  }
}