import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum PaymentDestinationType {
  PAYBILL = 'paybill',
  TILL = 'till',
  BANK = 'bank',
}

export enum ShadowBillingCycle {
  DAILY = 'daily',
  WEEKLY = 'weekly',
  MONTHLY = 'monthly',
}

export enum ShadowRelationshipStatus {
  UNVERIFIED = 'unverified',
  CONVERTED = 'converted',
  ENDED = 'ended',
}

@Entity('shadow_rental_relationships')
export class ShadowRentalRelationship {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  tenantUserId: string;

  @Column({ nullable: true })
  propertyNickname: string;

  @Column({ nullable: true })
  address: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  rentAmount: number;

  @Column({
    type: 'enum',
    enum: ShadowBillingCycle,
    default: ShadowBillingCycle.MONTHLY,
  })
  billingCycle: ShadowBillingCycle;

  @Column({ type: 'int', nullable: true })
  dueDayOfMonth: number;

  @Column({
    type: 'enum',
    enum: PaymentDestinationType,
  })
  paymentDestinationType: PaymentDestinationType;

  @Column()
  paymentDestinationNumber: string;

  @Column({ nullable: true })
  paymentReferenceName: string;

  @Column({
    type: 'enum',
    enum: ShadowRelationshipStatus,
    default: ShadowRelationshipStatus.UNVERIFIED,
  })
  status: ShadowRelationshipStatus;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}