import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  ShadowRentalRelationship,
  PaymentDestinationType,
  ShadowBillingCycle,
  ShadowRelationshipStatus,
} from './shadow-relationship.entity';

@Injectable()
export class ShadowRelationshipsService {
  constructor(
    @InjectRepository(ShadowRentalRelationship)
    private shadowRepository: Repository<ShadowRentalRelationship>,
  ) {}

  async create(data: {
    tenantUserId: string;
    propertyNickname?: string;
    address?: string;
    rentAmount: number;
    billingCycle?: ShadowBillingCycle;
    dueDayOfMonth?: number;
    paymentDestinationType: PaymentDestinationType;
    paymentDestinationNumber: string;
    paymentReferenceName?: string;
  }): Promise<ShadowRentalRelationship> {
    const relationship = this.shadowRepository.create({
      ...data,
      status: ShadowRelationshipStatus.UNVERIFIED,
    });
    return this.shadowRepository.save(relationship);
  }

  async findByTenant(
    tenantUserId: string,
  ): Promise<ShadowRentalRelationship[]> {
    return this.shadowRepository.find({
      where: { tenantUserId },
      order: { createdAt: 'DESC' },
    });
  }

  async findById(id: string, tenantUserId: string): Promise<ShadowRentalRelationship> {
    const relationship = await this.shadowRepository.findOne({
      where: { id, tenantUserId },
    });
    if (!relationship) {
      throw new NotFoundException('Rental relationship not found');
    }
    return relationship;
  }

  async update(
    id: string,
    tenantUserId: string,
    data: Partial<ShadowRentalRelationship>,
  ): Promise<ShadowRentalRelationship> {
    await this.findById(id, tenantUserId);
    await this.shadowRepository.update(id, data);
    return this.findById(id, tenantUserId);
  }

  async end(id: string, tenantUserId: string): Promise<ShadowRentalRelationship> {
    await this.findById(id, tenantUserId);
    await this.shadowRepository.update(id, {
      status: ShadowRelationshipStatus.ENDED,
    });
    return this.findById(id, tenantUserId);
  }
}
