import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { OtpService } from './otp.service';
import { Otp } from './otp.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Otp]), ConfigModule],
  providers: [OtpService],
  exports: [OtpService],
})
export class OtpModule {}