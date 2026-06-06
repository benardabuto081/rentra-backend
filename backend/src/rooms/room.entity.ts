import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum RoomStatus {
  VACANT = 'vacant',
  OCCUPIED = 'occupied',
  MAINTENANCE = 'maintenance',
  INACTIVE = 'inactive',
}

export enum RoomType {
  BEDSITTER = 'bedsitter',
  ONE_BEDROOM = 'one_bedroom',
  TWO_BEDROOM = 'two_bedroom',
  THREE_BEDROOM = 'three_bedroom',
  SINGLE_ROOM = 'single_room',
  SHOP = 'shop',
  OFFICE = 'office',
  STUDIO = 'studio',
}

@Entity('rooms')
export class Room {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column()
  buildingId: string;

  @Column()
  organizationId: string;

  @Column({ nullable: true })
  floor: number;

  @Column({
    type: 'enum',
    enum: RoomType,
    default: RoomType.BEDSITTER,
  })
  type: RoomType;

  @Column({
    type: 'enum',
    enum: RoomStatus,
    default: RoomStatus.VACANT,
  })
  status: RoomStatus;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  rentAmount: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  storageAmount: number;

  @Column({ nullable: true })
  description: string;

  @Column({ type: 'varchar', nullable: true })
currentTenantId: string | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}