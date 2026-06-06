import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Building, BuildingStatus } from './building.entity';

@Injectable()
export class BuildingsService {
  constructor(
    @InjectRepository(Building)
    private buildingsRepository: Repository<Building>,
  ) {}

  async create(data: {
    name: string;
    organizationId: string;
    address?: string;
    city?: string;
    county?: string;
    totalFloors?: number;
    description?: string;
  }): Promise<Building> {
    const building = this.buildingsRepository.create({
      ...data,
      status: BuildingStatus.ACTIVE,
    });
    return this.buildingsRepository.save(building);
  }

  async findAll(organizationId: string): Promise<Building[]> {
    return this.buildingsRepository.find({
      where: { organizationId, status: BuildingStatus.ACTIVE },
      order: { createdAt: 'DESC' },
    });
  }

  async findById(id: string, organizationId: string): Promise<Building> {
    const building = await this.buildingsRepository.findOne({
      where: { id, organizationId },
    });
    if (!building) {
      throw new NotFoundException('Building not found');
    }
    return building;
  }

  async update(
    id: string,
    organizationId: string,
    data: Partial<Building>,
  ): Promise<Building> {
    await this.findById(id, organizationId);
    await this.buildingsRepository.update(id, data);
    return this.findById(id, organizationId);
  }

  async deactivate(id: string, organizationId: string): Promise<Building> {
    await this.findById(id, organizationId);
    await this.buildingsRepository.update(id, {
      status: BuildingStatus.INACTIVE,
    });
    return this.findById(id, organizationId);
  }
}