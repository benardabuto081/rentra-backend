import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum MaintenanceStatus {
  PENDING = 'pending',
  IN_PROGRESS = 'in_progress',
  RESOLVED = 'resolved',
  CANCELLED = 'cancelled',
}

export enum MaintenancePriority {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  URGENT = 'urgent',
}

export enum MaintenanceCategory {
  PLUMBING = 'plumbing',
  ELECTRICAL = 'electrical',
  STRUCTURAL = 'structural',
  CLEANING = 'cleaning',
  SECURITY = 'security',
  APPLIANCE = 'appliance',
  OTHER = 'other',
}

@Entity('maintenance_requests')
export class MaintenanceRequest {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  organizationId: string;

  @Column()
  buildingId: string;

  @Column()
  roomId: string;

  @Column()
  tenantId: string;

  @Column({ nullable: true, type: 'varchar' })
  assignedTo: string | null;

  @Column()
  title: string;

  @Column({ type: 'text' })
  description: string;

  @Column({
    type: 'enum',
    enum: MaintenanceCategory,
    default: MaintenanceCategory.OTHER,
  })
  category: MaintenanceCategory;

  @Column({
    type: 'enum',
    enum: MaintenancePriority,
    default: MaintenancePriority.MEDIUM,
  })
  priority: MaintenancePriority;

  @Column({
    type: 'enum',
    enum: MaintenanceStatus,
    default: MaintenanceStatus.PENDING,
  })
  status: MaintenanceStatus;

  @Column({ type: 'text', nullable: true })
  resolutionNotes: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  cost: number | null;

  @Column({ type: 'timestamp', nullable: true })
  resolvedAt: Date | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}