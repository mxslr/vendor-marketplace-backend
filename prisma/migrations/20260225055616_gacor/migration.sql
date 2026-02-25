/*
  Warnings:

  - You are about to alter the column `price` on the `Gig` table. The data in that column could be lost. The data in that column will be cast from `Decimal(65,30)` to `Decimal(15,2)`.
  - The `status` column on the `Gig` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The `status` column on the `Merchant` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - You are about to alter the column `walletBalance` on the `Merchant` table. The data in that column could be lost. The data in that column will be cast from `Decimal(65,30)` to `Decimal(15,2)`.
  - You are about to alter the column `totalAmount` on the `Order` table. The data in that column could be lost. The data in that column will be cast from `Decimal(65,30)` to `Decimal(15,2)`.
  - A unique constraint covering the columns `[userId]` on the table `Merchant` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `categoryId` to the `Gig` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "MerchantStatus" AS ENUM ('INCOMPLETE', 'PENDING_VERIFICATION', 'ACTIVE', 'REJECTED', 'VACATION', 'SUSPENDED', 'CLOSED');

-- CreateEnum
CREATE TYPE "GigStatus" AS ENUM ('DRAFT', 'PENDING_APPROVAL', 'ACTIVE', 'PAUSED', 'REJECTED', 'REMOVED', 'FEATURED');

-- CreateEnum
CREATE TYPE "TransactionType" AS ENUM ('PAYMENT', 'REFUND', 'WITHDRAWAL', 'COMMISSION', 'AD_PAYMENT', 'ADJUSTMENT');

-- CreateEnum
CREATE TYPE "TransactionStatus" AS ENUM ('PENDING', 'VERIFIED', 'REJECTED');

-- CreateEnum
CREATE TYPE "DisputeStatus" AS ENUM ('OPEN', 'UNDER_REVIEW', 'RESOLVED', 'CLOSED');

-- CreateEnum
CREATE TYPE "CustomOfferStatus" AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED', 'EXPIRED');

-- CreateEnum
CREATE TYPE "MonthlyReportStatus" AS ENUM ('DRAFT', 'PROCESSED', 'LOCKED');

-- CreateEnum
CREATE TYPE "AssociatePermission" AS ENUM ('VIEW_ONLY', 'MANAGE_GIGS', 'MANAGE_ORDERS', 'FULL_ACCESS');

-- CreateEnum
CREATE TYPE "WithdrawalStatus" AS ENUM ('PENDING', 'COMPLETED', 'REJECTED');

-- CreateEnum
CREATE TYPE "FeaturedPaymentStatus" AS ENUM ('PENDING_PAYMENT', 'PENDING_VERIFICATION', 'ACTIVE', 'EXPIRED', 'REJECTED');

-- CreateEnum
CREATE TYPE "MerchantBadge" AS ENUM ('NEWCOMER', 'RISING_STAR', 'STAR_VENDOR', 'SIGNATURE_PARTNER');

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "OrderStatus" ADD VALUE 'REFUND_APPROVED_WAITING_FINANCE';
ALTER TYPE "OrderStatus" ADD VALUE 'RELEASE_APPROVED_WAITING_FINANCE';

-- DropForeignKey
ALTER TABLE "Order" DROP CONSTRAINT "Order_gigId_fkey";

-- AlterTable
ALTER TABLE "Gig" ADD COLUMN     "categoryId" INTEGER NOT NULL,
ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "mediaUrls" TEXT,
ADD COLUMN     "rejectionReason" TEXT,
ALTER COLUMN "price" SET DATA TYPE DECIMAL(15,2),
DROP COLUMN "status",
ADD COLUMN     "status" "GigStatus" NOT NULL DEFAULT 'DRAFT';

-- AlterTable
ALTER TABLE "Merchant" ADD COLUMN     "badge" "MerchantBadge" NOT NULL DEFAULT 'NEWCOMER',
ADD COLUMN     "bannerUrl" TEXT,
ADD COLUMN     "kybDocuments" TEXT,
ADD COLUMN     "logoUrl" TEXT,
ADD COLUMN     "pendingBalance" DECIMAL(15,2) NOT NULL DEFAULT 0.0,
ADD COLUMN     "rejectionReason" TEXT,
DROP COLUMN "status",
ADD COLUMN     "status" "MerchantStatus" NOT NULL DEFAULT 'INCOMPLETE',
ALTER COLUMN "walletBalance" SET DATA TYPE DECIMAL(15,2);

-- AlterTable
ALTER TABLE "Order" ADD COLUMN     "adminFee" DECIMAL(15,2) NOT NULL DEFAULT 0.0,
ADD COLUMN     "customOfferId" INTEGER,
ADD COLUMN     "deadline" TIMESTAMP(3),
ALTER COLUMN "gigId" DROP NOT NULL,
ALTER COLUMN "totalAmount" SET DATA TYPE DECIMAL(15,2);

-- CreateTable
CREATE TABLE "BankAccount" (
    "id" SERIAL NOT NULL,
    "merchantId" INTEGER NOT NULL,
    "bankName" TEXT NOT NULL,
    "accountNumber" TEXT NOT NULL,
    "accountHolderName" TEXT NOT NULL,
    "isPrimary" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "BankAccount_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MerchantAssociate" (
    "id" SERIAL NOT NULL,
    "merchantId" INTEGER NOT NULL,
    "userId" INTEGER NOT NULL,
    "permission" "AssociatePermission" NOT NULL DEFAULT 'VIEW_ONLY',

    CONSTRAINT "MerchantAssociate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Category" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "commissionRate" DECIMAL(5,2) NOT NULL,

    CONSTRAINT "Category_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FeaturedPlacement" (
    "id" SERIAL NOT NULL,
    "merchantId" INTEGER NOT NULL,
    "gigId" INTEGER NOT NULL,
    "durationDays" INTEGER NOT NULL,
    "amount" DECIMAL(15,2) NOT NULL,
    "status" "FeaturedPaymentStatus" NOT NULL DEFAULT 'PENDING_PAYMENT',
    "proofUrl" TEXT,
    "startDate" TIMESTAMP(3),
    "endDate" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "FeaturedPlacement_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OrderDeliverable" (
    "id" SERIAL NOT NULL,
    "orderId" INTEGER NOT NULL,
    "fileUrl" TEXT NOT NULL,
    "message" TEXT,
    "submittedBy" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "OrderDeliverable_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Review" (
    "id" SERIAL NOT NULL,
    "orderId" INTEGER NOT NULL,
    "clientId" INTEGER NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Review_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Dispute" (
    "id" SERIAL NOT NULL,
    "orderId" INTEGER NOT NULL,
    "reason" TEXT NOT NULL,
    "evidenceUrls" TEXT,
    "status" "DisputeStatus" NOT NULL DEFAULT 'OPEN',
    "validatorId" INTEGER,
    "verdictNote" TEXT,

    CONSTRAINT "Dispute_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Transaction" (
    "id" SERIAL NOT NULL,
    "orderId" INTEGER NOT NULL,
    "userId" INTEGER NOT NULL,
    "type" "TransactionType" NOT NULL,
    "amount" DECIMAL(15,2) NOT NULL,
    "status" "TransactionStatus" NOT NULL DEFAULT 'PENDING',
    "proofUrl" TEXT,
    "verifiedBy" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Transaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CustomOffer" (
    "id" SERIAL NOT NULL,
    "merchantId" INTEGER NOT NULL,
    "clientId" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "price" DECIMAL(15,2) NOT NULL,
    "deadlineDays" INTEGER NOT NULL,
    "status" "CustomOfferStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CustomOffer_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Withdrawal" (
    "id" SERIAL NOT NULL,
    "merchantId" INTEGER NOT NULL,
    "bankAccountId" INTEGER NOT NULL,
    "amount" DECIMAL(15,2) NOT NULL,
    "status" "WithdrawalStatus" NOT NULL DEFAULT 'PENDING',
    "proofUrl" TEXT,
    "processedBy" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "Withdrawal_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MonthlyReport" (
    "id" SERIAL NOT NULL,
    "period" TEXT NOT NULL,
    "totalGmv" DECIMAL(15,2) NOT NULL,
    "grossRevenue" DECIMAL(15,2) NOT NULL,
    "operationalCost" DECIMAL(15,2) NOT NULL,
    "netProfit" DECIMAL(15,2) NOT NULL,
    "cscShare" DECIMAL(15,2) NOT NULL,
    "cciShare" DECIMAL(15,2) NOT NULL,
    "status" "MonthlyReportStatus" NOT NULL DEFAULT 'DRAFT',
    "proofOfTransfer" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lockedAt" TIMESTAMP(3),

    CONSTRAINT "MonthlyReport_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "MerchantAssociate_merchantId_userId_key" ON "MerchantAssociate"("merchantId", "userId");

-- CreateIndex
CREATE UNIQUE INDEX "Review_orderId_key" ON "Review"("orderId");

-- CreateIndex
CREATE UNIQUE INDEX "Dispute_orderId_key" ON "Dispute"("orderId");

-- CreateIndex
CREATE UNIQUE INDEX "MonthlyReport_period_key" ON "MonthlyReport"("period");

-- CreateIndex
CREATE UNIQUE INDEX "Merchant_userId_key" ON "Merchant"("userId");

-- AddForeignKey
ALTER TABLE "BankAccount" ADD CONSTRAINT "BankAccount_merchantId_fkey" FOREIGN KEY ("merchantId") REFERENCES "Merchant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MerchantAssociate" ADD CONSTRAINT "MerchantAssociate_merchantId_fkey" FOREIGN KEY ("merchantId") REFERENCES "Merchant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MerchantAssociate" ADD CONSTRAINT "MerchantAssociate_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Gig" ADD CONSTRAINT "Gig_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "Category"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FeaturedPlacement" ADD CONSTRAINT "FeaturedPlacement_merchantId_fkey" FOREIGN KEY ("merchantId") REFERENCES "Merchant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FeaturedPlacement" ADD CONSTRAINT "FeaturedPlacement_gigId_fkey" FOREIGN KEY ("gigId") REFERENCES "Gig"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Order" ADD CONSTRAINT "Order_gigId_fkey" FOREIGN KEY ("gigId") REFERENCES "Gig"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Order" ADD CONSTRAINT "Order_customOfferId_fkey" FOREIGN KEY ("customOfferId") REFERENCES "CustomOffer"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OrderDeliverable" ADD CONSTRAINT "OrderDeliverable_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "Order"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OrderDeliverable" ADD CONSTRAINT "OrderDeliverable_submittedBy_fkey" FOREIGN KEY ("submittedBy") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Review" ADD CONSTRAINT "Review_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "Order"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Review" ADD CONSTRAINT "Review_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Dispute" ADD CONSTRAINT "Dispute_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "Order"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Dispute" ADD CONSTRAINT "Dispute_validatorId_fkey" FOREIGN KEY ("validatorId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "Order"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_verifiedBy_fkey" FOREIGN KEY ("verifiedBy") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CustomOffer" ADD CONSTRAINT "CustomOffer_merchantId_fkey" FOREIGN KEY ("merchantId") REFERENCES "Merchant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CustomOffer" ADD CONSTRAINT "CustomOffer_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Withdrawal" ADD CONSTRAINT "Withdrawal_merchantId_fkey" FOREIGN KEY ("merchantId") REFERENCES "Merchant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Withdrawal" ADD CONSTRAINT "Withdrawal_bankAccountId_fkey" FOREIGN KEY ("bankAccountId") REFERENCES "BankAccount"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
