import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum BuildingStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
}

@Entity('buildings')
export class Building {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column()
  organizationId: string;

  @Column({ nullable: true })
  address: string;

  @Column({ nullable: true })
  city: string;

  @Column({ nullable: true })
  county: string;

  @Column({ nullable: true })
  totalFloors: number;

  @Column({ nullable: true })
  description: string;

  @Column({ nullable: true })
  propertyType: string;

  @Column({
    type: 'enum',
    enum: BuildingStatus,
    default: BuildingStatus.ACTIVE,
  })
  status: BuildingStatus;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}