import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Organization, OrganizationStatus } from './organization.entity';

@Injectable()
export class OrganizationsService {
  constructor(
    @InjectRepository(Organization)
    private organizationsRepository: Repository<Organization>,
  ) {}

  async create(data: {
    name: string;
    ownerId: string;
    phone?: string;
    email?: string;
    address?: string;
    city?: string;
  }): Promise<Organization> {
    const organization = this.organizationsRepository.create({
      ...data,
      status: OrganizationStatus.ACTIVE,
    });
    return this.organizationsRepository.save(organization);
  }

  async findById(id: string): Promise<Organization> {
    const organization = await this.organizationsRepository.findOne({
      where: { id },
    });
    if (!organization) {
      throw new NotFoundException('Organization not found');
    }
    return organization;
  }

  async findByOwner(ownerId: string): Promise<Organization[]> {
    return this.organizationsRepository.find({ where: { ownerId } });
  }

  async update(
    id: string,
    data: Partial<Organization>,
  ): Promise<Organization> {
    await this.organizationsRepository.update(id, data);
    return this.findById(id);
  }
}
