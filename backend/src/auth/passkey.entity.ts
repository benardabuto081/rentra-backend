import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum PasskeyStatus {
  ACTIVE = 'active',
  USED = 'used',
  EXPIRED = 'expired',
  REVOKED = 'revoked',
}

@Entity('passkeys')
export class Passkey {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  code: string;

  @Column()
  unitId: string;

  @Column()
  organizationId: string;

  @Column()
  generatedBy: string;

  @Column({
    type: 'enum',
    enum: PasskeyStatus,
    default: PasskeyStatus.ACTIVE,
  })
  status: PasskeyStatus;

  @Column({ nullable: true })
  usedBy: string;

 @Column({ type: 'timestamp', nullable: true })
expiresAt: Date | null;

  @Column({ nullable: true })
  usedAt: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}