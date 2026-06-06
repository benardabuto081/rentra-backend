import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Room, RoomStatus, RoomType } from './room.entity';

@Injectable()
export class RoomsService {
  constructor(
    @InjectRepository(Room)
    private roomsRepository: Repository<Room>,
  ) {}

  async create(data: {
    name: string;
    buildingId: string;
    organizationId: string;
    floor?: number;
    type?: RoomType;
    rentAmount: number;
    storageAmount?: number;
    description?: string;
  }): Promise<Room> {
    const room = this.roomsRepository.create({
      ...data,
      status: RoomStatus.VACANT,
    });
    return this.roomsRepository.save(room);
  }

  async findAll(buildingId: string, organizationId: string): Promise<Room[]> {
    return this.roomsRepository.find({
      where: { buildingId, organizationId },
      order: { floor: 'ASC', name: 'ASC' },
    });
  }

  async findVacant(buildingId: string, organizationId: string): Promise<Room[]> {
    return this.roomsRepository.find({
      where: { buildingId, organizationId, status: RoomStatus.VACANT },
    });
  }

  async findById(id: string, organizationId: string): Promise<Room> {
    const room = await this.roomsRepository.findOne({
      where: { id, organizationId },
    });
    if (!room) {
      throw new NotFoundException('Room not found');
    }
    return room;
  }

  async update(
    id: string,
    organizationId: string,
    data: Partial<Room>,
  ): Promise<Room> {
    await this.findById(id, organizationId);
    await this.roomsRepository.update(id, data);
    return this.findById(id, organizationId);
  }

  async assignTenant(id: string, organizationId: string, tenantId: string): Promise<Room> {
    const room = await this.findById(id, organizationId);
    if (room.status === RoomStatus.OCCUPIED) {
      throw new BadRequestException('Room is already occupied');
    }
    await this.roomsRepository.update(id, {
      status: RoomStatus.OCCUPIED,
      currentTenantId: tenantId,
    });
    return this.findById(id, organizationId);
  }

  async vacateRoom(id: string, organizationId: string): Promise<Room> {
    await this.findById(id, organizationId);
    await this.roomsRepository.update(id, {
      status: RoomStatus.VACANT,
      currentTenantId: null,
    });
    return this.findById(id, organizationId);
  }
}
