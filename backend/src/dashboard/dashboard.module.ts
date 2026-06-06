import { Module } from '@nestjs/common';
import { DashboardService } from './dashboard.service';
import { DashboardController } from './dashboard.controller';
import { BuildingsModule } from '../buildings/buildings.module';
import { RoomsModule } from '../rooms/rooms.module';
import { TenantsModule } from '../tenants/tenants.module';
import { PaymentsModule } from '../payments/payments.module';
import { MaintenanceModule } from '../maintenance/maintenance.module';

@Module({
  imports: [
    BuildingsModule,
    RoomsModule,
    TenantsModule,
    PaymentsModule,
    MaintenanceModule,
  ],
  providers: [DashboardService],
  controllers: [DashboardController],
})
export class DashboardModule {}