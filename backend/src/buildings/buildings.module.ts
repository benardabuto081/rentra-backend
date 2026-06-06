import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BuildingsService } from './buildings.service';
import { BuildingsController } from './buildings.controller';
import { Building } from './building.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Building])],
  providers: [BuildingsService],
  controllers: [BuildingsController],
  exports: [BuildingsService],
})
export class BuildingsModule {}