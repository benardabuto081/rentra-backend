import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ShadowRelationshipsService } from './shadow-relationships.service';
import { ShadowRelationshipsController } from './shadow-relationships.controller';
import { ShadowRentalRelationship } from './shadow-relationship.entity';

@Module({
  imports: [TypeOrmModule.forFeature([ShadowRentalRelationship])],
  providers: [ShadowRelationshipsService],
  controllers: [ShadowRelationshipsController],
  exports: [ShadowRelationshipsService],
})
export class ShadowRelationshipsModule {}
