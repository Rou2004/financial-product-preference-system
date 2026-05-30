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
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `LikeList`
--

LOCK TABLES `LikeList` WRITE;
/*!40000 ALTER TABLE `LikeList` DISABLE KEYS */;
INSERT INTO `LikeList` VALUES (11,'B120987654',4,10,'700-00011112222333',1.6100,404.1100),(17,'A123456788',1,13,'700-11119999666602',130.0000,1430.0000),(18,'A123456788',6,10,'700-11119999666602',0.5850,195.5850),(19,'A123456788',12,40,'700-11119999666602',2.3560,1180.3560),(20,'A123456789',2,18,'700-00012345678901',9.0000,909.0000),(21,'A123456789',3,202,'700-00012345678901',81.6585,23412.6585),(22,'A123456789',8,32,'700-00012345678901',2.4384,815.2384),(23,'B120987654',5,13,'700-00011112222333',1.1856,297.5856),(24,'B120987654',10,109,'700-00011112222333',7.8971,2640.2471);
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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Product`
--

LOCK TABLES `Product` WRITE;
/*!40000 ALTER TABLE `Product` DISABLE KEYS */;
INSERT INTO `Product` VALUES (1,'主動統一台股增長(00981A)',100.0000,0.1000),(2,'元大臺灣50(0050)',50.0000,0.0100),(3,'富邦台50 (006208)',115.5000,0.0035),(4,'元大高股息 (0056)',40.2500,0.0040),(5,'國泰永續高股息 (00878)',22.8000,0.0040),(6,'復華台灣科技優息 (00929)',19.5000,0.0030),(7,'安聯台灣科技基金',185.0000,0.0150),(8,'群益台灣精選高息 (00919)',25.4000,0.0030),(9,'元大台灣高息低波 (00713)',57.2000,0.0035),(10,'大華優利高填息30 (00918)',24.1500,0.0030),(11,'凱基台灣優選高股息 (00915)',26.8000,0.0030),(12,'元大美債20年 (00679B)',29.4500,0.0020);
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
  `Password` varchar(50) NOT NULL,
  PRIMARY KEY (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `User`
--

LOCK TABLES `User` WRITE;
/*!40000 ALTER TABLE `User` DISABLE KEYS */;
INSERT INTO `User` VALUES ('A123456788','王ｏ明','test@email.com','700-11119999666602','1234'),('A123456789','陳ｏ柔','annie@gmail.com','700-00012345678901','1234'),('B120987654','張ｏ同','datong@gmail.com','700-00011112222333','1234');
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

-- Dump completed on 2026-05-30 21:21:45
