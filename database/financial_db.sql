CREATE DATABASE  IF NOT EXISTS `financial_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `financial_db`;
-- MySQL dump 10.13  Distrib 8.0.34, for macos13 (arm64)
--
-- Host: 127.0.0.1    Database: financial_db
-- ------------------------------------------------------
-- Server version	9.0.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `LikeList`
--

DROP TABLE IF EXISTS `LikeList`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `LikeList` (
  `SN` int NOT NULL AUTO_INCREMENT COMMENT '流水序號',
  `UserID` varchar(50) NOT NULL COMMENT '關聯的使用者 ID (Foreign Key)',
  `ProductNo` int NOT NULL COMMENT '關聯的產品流水號 (Foreign Key)',
  `PurchaseQuantity` int NOT NULL COMMENT '購買數量',
  `Account` varchar(50) NOT NULL COMMENT '扣款帳號',
  `TotalFee` decimal(18,4) NOT NULL COMMENT '總手續費用(台幣計價)',
  `TotalAmount` decimal(18,4) NOT NULL COMMENT '預計扣款總金額',
  PRIMARY KEY (`SN`),
  KEY `FK_LikeList_User` (`UserID`),
  KEY `FK_LikeList_Product` (`ProductNo`),
  CONSTRAINT `FK_LikeList_Product` FOREIGN KEY (`ProductNo`) REFERENCES `Product` (`No`) ON DELETE CASCADE,
  CONSTRAINT `FK_LikeList_User` FOREIGN KEY (`UserID`) REFERENCES `User` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `LikeList`
--

LOCK TABLES `LikeList` WRITE;
/*!40000 ALTER TABLE `LikeList` DISABLE KEYS */;
INSERT INTO `LikeList` VALUES (2,'A1236456789',2,45,'11119999666',22.5000,2272.5000),(3,'A1236456789',2,10,'11119999666',5.0000,505.0000),(5,'A1234567890',1,13,'1230000',130.0000,1430.0000);
/*!40000 ALTER TABLE `LikeList` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Product`
--

DROP TABLE IF EXISTS `Product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Product` (
  `No` int NOT NULL AUTO_INCREMENT COMMENT '產品流水號',
  `ProductName` varchar(150) NOT NULL COMMENT '產品名稱',
  `Price` decimal(18,4) NOT NULL COMMENT '產品價格',
  `FeeRate` decimal(5,4) NOT NULL COMMENT '手續費率(%)',
  PRIMARY KEY (`No`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Product`
--

LOCK TABLES `Product` WRITE;
/*!40000 ALTER TABLE `Product` DISABLE KEYS */;
INSERT INTO `Product` VALUES (1,'主動統一台股增長',100.0000,0.1000),(2,'元大臺灣50',50.0000,0.0100);
/*!40000 ALTER TABLE `Product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `User`
--

DROP TABLE IF EXISTS `User`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `User` (
  `UserID` varchar(50) NOT NULL COMMENT '使用者 ID (Primary Key)',
  `UserName` varchar(100) NOT NULL COMMENT '使用者名稱',
  `Email` varchar(150) NOT NULL COMMENT '使用者電子郵件',
  `Account` varchar(50) NOT NULL COMMENT '扣款帳號',
  PRIMARY KEY (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `User`
--

LOCK TABLES `User` WRITE;
/*!40000 ALTER TABLE `User` DISABLE KEYS */;
INSERT INTO `User` VALUES ('A1234567890','陳小柔','annie@gmail.com','1230000'),('A1236456789','王ｏ明','test@email.com','11119999666');
/*!40000 ALTER TABLE `User` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-30 16:37:57
