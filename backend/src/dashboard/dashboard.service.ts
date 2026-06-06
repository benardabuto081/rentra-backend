import { Injectable } from '@nestjs/common';
import { BuildingsService } from '../buildings/buildings.service';
import { RoomsService } from '../rooms/rooms.service';
import { TenantsService } from '../tenants/tenants.service';
import { PaymentsService } from '../payments/payments.service';
import { MaintenanceService } from '../maintenance/maintenance.service';
import { RoomStatus } from '../rooms/room.entity';
import { TenantStatus } from '../tenants/tenant.entity';

@Injectable()
export class DashboardService {
  constructor(
    private buildingsService: BuildingsService,
    private roomsService: RoomsService,
    private tenantsService: TenantsService,
    private paymentsService: PaymentsService,
    private maintenanceService: MaintenanceService,
  ) {}

  async getOverview(organizationId: string) {
    const buildings = await this.buildingsService.findAll(organizationId);
    const allTenants = await this.tenantsService.findAll(organizationId);
    const activeTenants = allTenants.filter(
      (t) => t.status === TenantStatus.ACTIVE,
    );
    const noticeTenants = allTenants.filter(
      (t) => t.status === TenantStatus.NOTICE,
    );
    const pendingMaintenance =
      await this.maintenanceService.findPending(organizationId);

    return {
      totalBuildings: buildings.length,
      totalActiveTenants: activeTenants.length,
      totalNoticeTenants: noticeTenants.length,
      totalPendingMaintenance: pendingMaintenance.length,
    };
  }

  async getFinancialSummary(
    organizationId: string,
    month: number,
    year: number,
  ) {
    const stats = await this.paymentsService.getMonthlyStats(
      organizationId,
      month,
      year,
    );
    const arrears = await this.paymentsService.findArrears(organizationId);

    const totalArrears = arrears.reduce(
      (sum, p) => sum + (Number(p.amount) - Number(p.amountPaid)),
      0,
    );

    return {
      month,
      year,
      totalExpected: stats.totalExpected,
      totalCollected: stats.totalCollected,
      collectionRate:
        stats.totalExpected > 0
          ? Math.round((stats.totalCollected / stats.totalExpected) * 100)
          : 0,
      totalOutstandingArrears: totalArrears,
      totalArrearsCount: arrears.length,
    };
  }

  async getBuildingSummary(organizationId: string) {
    const buildings = await this.buildingsService.findAll(organizationId);

    const summaries = await Promise.all(
      buildings.map(async (building) => {
        const allRooms = await this.roomsService.findAll(
          building.id,
          organizationId,
        );
        const vacantRooms = allRooms.filter(
          (r) => r.status === RoomStatus.VACANT,
        );
        const occupiedRooms = allRooms.filter(
          (r) => r.status === RoomStatus.OCCUPIED,
        );
        const occupancyRate =
          allRooms.length > 0
            ? Math.round((occupiedRooms.length / allRooms.length) * 100)
            : 0;

        return {
          buildingId: building.id,
          buildingName: building.name,
          totalRooms: allRooms.length,
          occupiedRooms: occupiedRooms.length,
          vacantRooms: vacantRooms.length,
          occupancyRate: `${occupancyRate}%`,
        };
      }),
    );

    return summaries;
  }
}