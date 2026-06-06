import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  MaintenanceRequest,
  MaintenanceStatus,
  MaintenancePriority,
  MaintenanceCategory,
} from './maintenance.entity';

@Injectable()
export class MaintenanceService {
  constructor(
    @InjectRepository(MaintenanceRequest)
    private maintenanceRepository: Repository<MaintenanceRequest>,
  ) {}

  async create(data: {
    organizationId: string;
    buildingId: string;
    roomId: string;
    tenantId: string;
    title: string;
    description: string;
    category?: MaintenanceCategory;
    priority?: MaintenancePriority;
  }): Promise<MaintenanceRequest> {
    const request = this.maintenanceRepository.create({
      ...data,
      status: MaintenanceStatus.PENDING,
    });
    return this.maintenanceRepository.save(request);
  }

  async findAll(organizationId: string): Promise<MaintenanceRequest[]> {
    return this.maintenanceRepository.find({
      where: { organizationId },
      order: { createdAt: 'DESC' },
    });
  }

  async findPending(organizationId: string): Promise<MaintenanceRequest[]> {
    return this.maintenanceRepository.find({
      where: { organizationId, status: MaintenanceStatus.PENDING },
      order: { createdAt: 'ASC' },
    });
  }

  async findByTenant(tenantId: string, organizationId: string): Promise<MaintenanceRequest[]> {
    return this.maintenanceRepository.find({
      where: { tenantId, organizationId },
      order: { createdAt: 'DESC' },
    });
  }

  async findByRoom(roomId: string, organizationId: string): Promise<MaintenanceRequest[]> {
    return this.maintenanceRepository.find({
      where: { roomId, organizationId },
      order: { createdAt: 'DESC' },
    });
  }

  async findById(id: string, organizationId: string): Promise<MaintenanceRequest> {
    const request = await this.maintenanceRepository.findOne({
      where: { id, organizationId },
    });
    if (!request) {
      throw new NotFoundException('Maintenance request not found');
    }
    return request;
  }

  async assign(
    id: string,
    organizationId: string,
    assignedTo: string,
  ): Promise<MaintenanceRequest> {
    await this.findById(id, organizationId);
    await this.maintenanceRepository.update(id, {
      assignedTo,
      status: MaintenanceStatus.IN_PROGRESS,
    });
    return this.findById(id, organizationId);
  }

  async resolve(
    id: string,
    organizationId: string,
    data: {
      resolutionNotes: string;
      cost?: number;
    },
  ): Promise<MaintenanceRequest> {
    const request = await this.findById(id, organizationId);
    if (request.status === MaintenanceStatus.RESOLVED) {
      throw new BadRequestException('Request is already resolved');
    }
    await this.maintenanceRepository.update(id, {
      status: MaintenanceStatus.RESOLVED,
      resolutionNotes: data.resolutionNotes,
      cost: data.cost ?? null,
      resolvedAt: new Date(),
    });
    return this.findById(id, organizationId);
  }

  async cancel(id: string, organizationId: string): Promise<MaintenanceRequest> {
    await this.findById(id, organizationId);
    await this.maintenanceRepository.update(id, {
      status: MaintenanceStatus.CANCELLED,
    });
    return this.findById(id, organizationId);
  }

  async updatePriority(
    id: string,
    organizationId: string,
    priority: MaintenancePriority,
  ): Promise<MaintenanceRequest> {
    await this.findById(id, organizationId);
    await this.maintenanceRepository.update(id, { priority });
    return this.findById(id, organizationId);
  }
}