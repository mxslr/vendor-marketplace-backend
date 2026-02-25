import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class GigsService {
constructor(private prisma: PrismaService) {}

async createGig(userId: number, categoryId: number, title: string, description: string, price: number) {
    const myMerchant = await this.prisma.merchant.findFirst({
      where: { userId: userId },
    });

    if (!myMerchant) {
      throw new NotFoundException('Saya belum punya toko. Bikin toko dulu ya.');
    }

    return this.prisma.gig.create({
      data: {
        merchantId: myMerchant.id,
        categoryId: categoryId, 
        title: title,
        description: description,
        price: price,
      },
    });
  }

async findAllGigs() {
    return this.prisma.gig.findMany({
    include: { 
        merchant: true, 
    },
    });
}
}