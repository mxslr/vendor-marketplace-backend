import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService, } from '../prisma/prisma.service';
import { MerchantStatus } from '@prisma/client';

@Injectable()
export class MerchantsService {
    constructor(private prisma: PrismaService) {}

async createMerchant(userId: number, shopName: string, description?: string) {
    const existingMerchant = await this.prisma.merchant.findUnique({
    where: { userId: userId },
    });

    if (existingMerchant) {
    throw new BadRequestException('Akun ini sudah memiliki toko. Satu akun hanya bisa membuat satu toko.');
    }

    return this.prisma.merchant.create({
    data: {
        userId: userId,
        shopName: shopName,
        description: description,
        status: MerchantStatus.INCOMPLETE,
    },
    });
}

    async submitKyb(userId: number, kybDocumentsUrl: string) {
    const merchant = await this.prisma.merchant.findUnique({ where: { userId: userId } });
    if (!merchant) throw new NotFoundException('Toko tidak ditemukan.');

    if (merchant.status !== 'INCOMPLETE' && merchant.status !== 'REJECTED') {
        throw new BadRequestException('Toko sudah diverifikasi atau sedang dalam antrean.');
    }

    return this.prisma.merchant.update({
        where: { id: merchant.id },
        data: {
        kybDocuments: kybDocumentsUrl, 
        status: 'PENDING_VERIFICATION', 
        rejectionReason: null, 
        },
    });
    }

async findAllMerchants() {
    return this.prisma.merchant.findMany();
}
async approveMerchant(merchantId: number) {
    return this.prisma.merchant.update({
    where: { id: merchantId },
    data: { status: MerchantStatus.ACTIVE }, 
    });
}
}

