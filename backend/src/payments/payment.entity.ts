import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum PaymentType {
  RENT = 'rent',
  STORAGE = 'storage',
  DEPOSIT = 'deposit',
  UTILITY = 'utility',
  PENALTY = 'penalty',
  OTHER = 'other',
}

export enum PaymentStatus {
  PENDING = 'pending',
  COMPLETED = 'completed',
  FAILED = 'failed',
  PARTIAL = 'partial',
}

export enum PaymentMethod {
  MPESA = 'mpesa',
  CASH = 'cash',
  BANK = 'bank',
  OTHER = 'other',
}

@Entity('payments')
export class Payment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  organizationId: string;

  @Column()
  tenantId: string;

  @Column()
  roomId: string;

  @Column()
  buildingId: string;

  @Column({
    type: 'enum',
    enum: PaymentType,
    default: PaymentType.RENT,
  })
  type: PaymentType;

  @Column({
    type: 'enum',
    enum: PaymentStatus,
    default: PaymentStatus.PENDING,
  })
  status: PaymentStatus;

  @Column({
    type: 'enum',
    enum: PaymentMethod,
    default: PaymentMethod.CASH,
  })
  method: PaymentMethod;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  amount: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  amountPaid: number;

  @Column({ type: 'int' })
  month: number;

  @Column({ type: 'int' })
  year: number;

  @Column({ nullable: true })
  mpesaCode: string;

  @Column({ nullable: true })
  receiptNumber: string;

  @Column({ nullable: true })
  notes: string;

  @Column({ type: 'timestamp', nullable: true })
  dueDate: Date | null;

  @Column({ type: 'int', nullable: true, default: 0 })
  daysLate: number;

  @Column({ type: 'timestamp', nullable: true })
  paidAt: Date | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}