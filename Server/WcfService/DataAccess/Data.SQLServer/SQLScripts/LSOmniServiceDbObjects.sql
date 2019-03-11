-- use  collation  SQL_Latin1_General_CP1_CI_AS   not Icelandic_CI_AS   use COLLATE DATABASE_DEFAULT in select from #temp tables  
/*
if (SERVERPROPERTY('IsFullTextInstalled') = 0)
 Begin;
  RAISERROR ('Full-Text search is not installed. Sql Server must have Full-Text Search feature installed to continue...', -- Message text.
               16, -- Severity.
               1 -- State.
               );
 End 
 */
 
----------------------------
 -- Contact
---------------------------- 
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'Contact' and xtype='U')
    DROP TABLE [dbo].[Contact]
go
CREATE TABLE [dbo].[Contact](
    [Id] nvarchar(20) NOT NULL,
	[AlternateId] nvarchar(50) NULL,
    [AccountId] nvarchar(20) NOT NULL,
    [FirstName] nvarchar(30) NOT NULL,
    [MiddleName] nvarchar(30) NULL,
    [LastName] nvarchar(30) NOT NULL,
    [Email] nvarchar(80) NULL,
    [CreateDate] datetime NOT NULL DEFAULT getdate(),
    [ContactStatus] bit NULL,     -- contact is blocked when this is not null
    [BlockedReason] nvarchar(10) NULL,
    [BlockedDate] datetime  NULL,
    [BlockedBy] nvarchar(20) NULL,

CONSTRAINT [PK_Contact] PRIMARY KEY NONCLUSTERED  
( [Id] ASC) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)  
) ON [PRIMARY] 
go
--filtered index 
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Contact]') AND name = N'IX_Contact_AlternateId')
CREATE UNIQUE NONCLUSTERED INDEX [IX_Contact_AlternateId] ON [dbo].[Contact] 
(
    [AlternateId] ASC
) where AlternateId is not null 
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
go  
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Contact]') AND name = N'IX_Contact_Email')
CREATE NONCLUSTERED INDEX [IX_Contact_Email] ON [dbo].[Contact]
(
	[Email] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

----------------------------
 -- ContactProfile
----------------------------
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'ContactProfile' and xtype='U')
    DROP TABLE [dbo].[ContactProfile]
go
CREATE TABLE [ContactProfile](
    [ClubId] nvarchar(10) NOT NULL,
    [AccountId] nvarchar(20) NOT NULL,
    [ContactId] nvarchar(20) NOT NULL,
    [ProfileId] nvarchar(20) NOT NULL,
    [Value] nvarchar(20) NULL,
    [OmniValue] nvarchar(20) NULL,  --v2.1.1 added OmniValue
    ReplicationCounter int NOT NULL,
    [Status] int NULL, -- status 0=active, 1=closed
    [ActivationDate] datetime NULL,
 CONSTRAINT PK_ContactProfile PRIMARY KEY([AccountId],[ContactId],[ProfileId]) );
 GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ContactProfile]') AND name = N'IX_ContactProfile_ReplicationCounter')
CREATE NONCLUSTERED   INDEX [IX_ContactProfile_ReplicationCounter] ON [dbo].[ContactProfile] 
(
    [ReplicationCounter] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
go  

----------------------------
 -- LoginLog
---------------------------- 
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'LoginLog' and xtype='U')
    DROP TABLE [dbo].[LoginLog]
go
CREATE TABLE [dbo].[LoginLog](
    [Id]  int IDENTITY(1,1) NOT NULL,
    [UserName] nvarchar(50) NOT NULL,
    [LoginType] nvarchar(1) NOT NULL DEFAULT ('I')  CHECK (LoginType in ('I','O','i','o')),  -- I login  O logout
    [Failed] bit NOT NULL DEFAULT (0),
    [IPAddress] nvarchar(45) NULL,  --  - -ipv6 can be 45 chars
    [DeviceId] nvarchar(50) NULL,
    [CreateDate] datetime NOT NULL DEFAULT getdate(),
CONSTRAINT [PK_LoginLog] PRIMARY KEY NONCLUSTERED  
( [Id] ASC) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
) ON [PRIMARY] 
go
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Contact]') AND name = N'IX_LoginLog_UserName')
CREATE NONCLUSTERED   INDEX [IX_LoginLog_UserName] ON [dbo].[LoginLog] 
(
    [UserName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
go

----------------------------
 -- Club
---------------------------- 
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'Club' and xtype='U')
    DROP TABLE [dbo].[Club]
go
CREATE TABLE [dbo].[Club](
    [Id] nvarchar(10) NOT NULL,
    [Description] nvarchar(30) NOT NULL,
CONSTRAINT [PK_Club] PRIMARY KEY NONCLUSTERED  
( [Id] ASC) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)  
) ON [PRIMARY] 
go

----------------------------
 -- Scheme
---------------------------- 
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'Scheme' and xtype='U')
    DROP TABLE [dbo].[Scheme]
go
CREATE TABLE [dbo].[Scheme](
    [Id] nvarchar(10) NOT NULL,
    [Description] nvarchar(30) NOT NULL,
    [ClubId] nvarchar(10) NOT NULL,
    [UpdateSequence] int NULL,
    [MinPointsToUpgrade] decimal(18, 0) NULL,
    [NextSchemeBenefits] nvarchar(160) NULL,
CONSTRAINT [PK_Scheme] PRIMARY KEY NONCLUSTERED  
( [Id] ASC) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)  
) ON [PRIMARY] 
go

----------------------------
 -- Account
---------------------------- 
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'Account' and xtype='U')
    DROP TABLE [dbo].[Account]
go
CREATE TABLE [dbo].[Account](
    [Id] nvarchar(20) NOT NULL,
    [SchemeId] nvarchar(10) NOT NULL,
    [Balance] decimal(15, 4) NOT NULL DEFAULT (0.0),
CONSTRAINT [PK_Account] PRIMARY KEY NONCLUSTERED  
( [Id] ASC) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
) ON [PRIMARY] 
go

----------------------------
 -- Card
---------------------------- 
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'Card' and xtype='U')
    DROP TABLE [dbo].[Card]
go
CREATE TABLE [dbo].[Card](
    [Id] nvarchar(100) NOT NULL,
    [ContactId] nvarchar(20) NOT NULL,
    [ClubId] nvarchar(10) NULL DEFAULT(''),    ----JIJ v1.1 added  
    [CardStatus] int NOT NULL,   --  Free, Allocated, Active, Blocked
    [BlockedReason] nvarchar(10) NULL,
    [BlockedDate] datetime  NULL  ,
    [BlockedBy] nvarchar(20) NULL,
CONSTRAINT [PK_Card] PRIMARY KEY NONCLUSTERED  
( [Id] ASC) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)  
) ON [PRIMARY] 
go
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Card]') AND name = N'IX_ContactId_Card')
CREATE NONCLUSTERED INDEX [IX_ContactId_Card] ON [dbo].[Card] 
(
    [ContactId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

----------------------------
 -- Device
---------------------------- 
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'Device' and xtype='U')
    DROP TABLE [dbo].[Device] 
go
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Device]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Device](
    [Id] nvarchar(50) NOT NULL,
    [DeviceFriendlyName] nvarchar(50) NOT NULL DEFAULT (''),
    [DeviceStatus] int NOT NULL,   -- Free, Allocated, Active, Blocked
    [BlockedReason] nvarchar(10) NULL,
    [BlockedDate] datetime NULL ,
    [BlockedBy] nvarchar(20) NULL,
    [Platform] nvarchar(50) NULL,     -- wp7, ios, android, blackberry etc
    [OsVersion] nvarchar(50) NULL,   -- (wp7 silverligth, iphone,  ipad, andoid, etc, looking for android version ) 
    [Manufacturer] nvarchar(50) NULL,   -- (Apple, Samsung, nokia, motorola etc)
    [Model] nvarchar(50) NULL,      --(iphone 4s,  Nokia 800, Galaxy Y, etc)
 CONSTRAINT [PK_Device] PRIMARY KEY NONCLUSTERED 
(
    [Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)  
) ON [PRIMARY]
END
GO

----------------------------
 -- User
---------------------------- 
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'User' and xtype='U')
    DROP TABLE [dbo].[User]
go
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[User]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[User](
    [UserId] nvarchar(50) NOT NULL,
    [Password] nvarchar(250) NOT NULL,
    [Blocked] tinyint NOT NULL,
	[LastAccessed] datetime NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
    [UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)  
) ON [PRIMARY]
END
GO

----------------------------
 -- UserCard,
---------------------------- 
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'UserCard' and xtype='U')
    DROP TABLE [dbo].[UserCard]
go
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserCard]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[UserCard](
    [CardId] nvarchar(100) NOT NULL,
    [UserId] nvarchar(50) NOT NULL,
 CONSTRAINT [PK_UserCard] PRIMARY KEY CLUSTERED 
(
    [CardId] ASC,
    [UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)  
) ON [PRIMARY]
END
GO

----------------------------
 -- UserDevice
---------------------------- 
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'UserDevice' and xtype='U')
    DROP TABLE [dbo].[UserDevice]
go
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserDevice]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[UserDevice](
    [DeviceId] nvarchar(50) NOT NULL,
    [UserId] nvarchar(50) NOT NULL,
 CONSTRAINT [PK_UserDevice] PRIMARY KEY CLUSTERED 
(
    [UserId] ASC,
    [DeviceId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)  
) ON [PRIMARY]
END
GO

----------------------------
 -- DeviceSecurity
---------------------------- 
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'DeviceSecurity' and xtype='U')
    DROP TABLE [dbo].[DeviceSecurity]
go
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeviceSecurity]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[DeviceSecurity](
    [SecurityToken] nvarchar(50) NOT NULL,
    [DeviceId] nvarchar(50) NOT NULL,
    [FcmToken] nvarchar(200) NULL,
    [ContactId] nvarchar(20) NOT NULL,
    [Created] datetime NOT NULL DEFAULT (getdate()),
 CONSTRAINT [PK_DeviceSecurity] PRIMARY KEY CLUSTERED 
(
	[DeviceId],[ContactId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DeviceSecurity]') AND name = N'IX_DeviceId_DeviceSecurity')
CREATE NONCLUSTERED INDEX [IX_DeviceId_DeviceSecurity] ON [dbo].[DeviceSecurity] 
(
    [DeviceId],[ContactId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

----------------------------
 -- Notification
---------------------------- 
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'Notification' and xtype='U')
    DROP TABLE [dbo].[Notification]
go
CREATE TABLE [dbo].[Notification](
    [Id] nvarchar(50) NOT NULL,
    [Type] int NOT NULL,     -- 0=Account,1=Contact,2=Club,3=Scheme    
    [TypeCode] nvarchar(20) NOT NULL,
    [PrimaryText] nvarchar(500) NOT NULL,
    [SecondaryText] nvarchar(2000) NULL,
    [DisplayFrequency] int NULL,    --Always,Once
    [ValidFrom] datetime NULL,
    [ValidTo] datetime NULL,
    [Created] datetime NULL,
    [CreatedBy] nvarchar(50) NULL,
    [LastModifiedDate] datetime NULL DEFAULT (getdate()) , --date replicated to table -- JIJ v2.0 added this new col
    [DateLastModified] datetime NULL DEFAULT (getdate()) , --date inserted to table    -- JIJ v2.0 added this new col
    [QRText] nvarchar(1000)  NULL DEFAULT (''),  -- JIJ v2.0 added this new col
    [NotificationType] int  NULL DEFAULT (0),   --0 NAV  1 LSOmni  -- JIJ v2.0 added this new col
    [Status] int NULL DEFAULT (1),  --0 disabled, 1=Enabled  -- JIJ v2.1.1 added this new col
 CONSTRAINT [PK_Notification] PRIMARY KEY NONCLUSTERED 
(
    [Id] ASC,
	[TypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)  
) ON [PRIMARY] 
go
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Notification]') AND name = N'IX_Notification_TypeCode')
CREATE NONCLUSTERED   INDEX [IX_Notification_TypeCode] ON [dbo].[Notification] 
(
    [TypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
go 
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Notification]') AND name = N'IX_Notification_LastModifiedDate')
CREATE NONCLUSTERED   INDEX [IX_Notification_LastModifiedDate] ON [dbo].[Notification] 
(
    [LastModifiedDate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
go 

----------------------------
 -- NotificationLog
---------------------------- 
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'NotificationLog' and xtype='U')
    DROP TABLE [dbo].[NotificationLog]
go
CREATE TABLE [dbo].[NotificationLog](
    [Id] nvarchar(50) NOT NULL,
    [ContactId] nvarchar(20) NOT NULL,
    [DateDisplayed] datetime NULL  ,
    [DeviceId] nvarchar(50) NOT NULL,
    [DateClosed] datetime NULL  ,
    [ReplicationCounter] int NOT NULL,
    [NotificationStatus] int NULL ,  -- 0=New 1=Read,  2=Closed
 CONSTRAINT [PK_NotificationLog] PRIMARY KEY CLUSTERED 
(
    [Id] ASC,
    [ContactId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)  
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[NotificationLog]') AND name = N'IX_NotificationLog_ReplicationCounter')
CREATE NONCLUSTERED   INDEX [IX_NotificationLog_ReplicationCounter] ON [dbo].[NotificationLog] 
(
    [ReplicationCounter] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
go  
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[NotificationLog]') AND name = N'IX_NotificationLog_ContactId')
CREATE NONCLUSTERED   INDEX [IX_NotificationLog_ContactId] ON [dbo].[NotificationLog] 
(
    [ContactId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
go  

----------------------------
 -- PushNotification
---------------------------- 
  IF EXISTS(SELECT * FROM sysobjects WHERE name = N'PushNotification' and xtype='U')
    DROP TABLE [dbo].[PushNotification]
go
CREATE TABLE [dbo].[PushNotification](
	[NotificationId] nvarchar(50) NOT NULL,
	[ContactId] nvarchar(200) NOT NULL,
	[DateCreated] datetime NOT NULL DEFAULT getdate(),
	[LastModified] datetime NOT NULL DEFAULT getdate(),
	[DateSent] datetime NULL DEFAULT NULL,
	[RetryCounter] int NOT NULL DEFAULT ('0'),
 CONSTRAINT [PK_PushNotification_1] PRIMARY KEY CLUSTERED 
(
	[NotificationId] ASC,
	[ContactId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO 
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[PushNotification]') AND name = N'IX_PushNotification_Id')
CREATE NONCLUSTERED   INDEX [IX_PushNotification_Id] ON [dbo].[PushNotification] 
(
    [NotificationId],[ContactId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
go  

----------------------------
 -- OneList 
----------------------------
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'OneList' and xtype='U')
    DROP TABLE [dbo].OneList
go
CREATE TABLE [dbo].OneList(
    [Id] uniqueidentifier NOT NULL,
	[IsDefaultList] bit NOT NULL DEFAULT(0),
    [Description] nvarchar(100) NOT NULL,
	[CardId] nvarchar(500) NOT NULL DEFAULT(''),
	[CustomerId] nvarchar(500) NOT NULL DEFAULT(''),
    [ContactId] nvarchar(20) NOT NULL,
    [StoreId] nvarchar(50) NULL DEFAULT ('') ,
	[ListType] int NOT NULL DEFAULT('0'),  -- 0= Basket, 1=wishlist
	[TotalAmount] decimal(19, 8),
    [TotalNetAmount] decimal(19, 8),
    [TotalTaxAmount] decimal(19, 8),
    [TotalDiscAmount] decimal(19, 8),
    [ShippingAmount] decimal(19, 8),
    [CreateDate] datetime NOT NULL DEFAULT getdate(),
	[LastAccessed] datetime NULL,
PRIMARY KEY NONCLUSTERED 
( [Id] ASC) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)  
) ON [PRIMARY] 
go
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[OneList]') AND name = N'IX_ContactId_OneList')
CREATE NONCLUSTERED INDEX [IX_ContactId_OneList] ON [dbo].[OneList] 
(
    [ContactId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO 

----------------------------
 --  OneListItem  ----JIJ v2.1 added  
----------------------------
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'OneListItem' and xtype='U')
    DROP TABLE [dbo].[OneListItem]
go
CREATE TABLE [dbo].[OneListItem](
    [Id] uniqueidentifier NOT NULL,
    [OneListId] uniqueidentifier NOT NULL, 
	[DisplayOrderId] int NOT NULL,
    [ItemId] nvarchar(20) NOT NULL,
	[ItemDescription] nvarchar(50),
    [BarcodeId] nvarchar(20) NOT NULL DEFAULT(''),
    [UomId] nvarchar(10) DEFAULT(''),
    [VariantId] nvarchar(20) DEFAULT(''),
    [Quantity] decimal(19, 8) NOT NULL,
	[NetPrice] decimal(19, 8),
    [Price] decimal(19, 8),
    [NetAmount] decimal(19, 8),
    [TaxAmount] decimal(19, 8),
    [DiscountAmount] decimal(19, 8),
    [DiscountPercent] decimal(19, 8),
    [CreateDate] datetime NOT NULL DEFAULT getdate(),
PRIMARY KEY NONCLUSTERED 
( [Id] ASC) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
) ON [PRIMARY] 
go 
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[OneListItem]') AND name = N'IX_OneListId_OneListItem')
CREATE NONCLUSTERED INDEX [IX_OneListId_OneListItem] ON [dbo].[OneListItem] 
(
    [OneListId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO  

----------------------------
 --  OneListOffer
----------------------------
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'OneListOffer' and xtype='U')
    DROP TABLE [dbo].[OneListOffer]
go
CREATE TABLE [dbo].[OneListOffer](
    [OfferId] nvarchar(20) NOT NULL,
    [OneListId] uniqueidentifier NOT NULL, 
	[DisplayOrderId] int NOT NULL,
    [CreateDate] datetime NOT NULL DEFAULT getdate(),
PRIMARY KEY NONCLUSTERED 
( [OfferId],[OneListId] ASC) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
) ON [PRIMARY] 
go 
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[OneListOffer]') AND name = N'IX_OneListId_OneListOffer')
CREATE NONCLUSTERED INDEX [IX_OneListId_OneListOffer] ON [dbo].[OneListOffer] 
(
    [OneListId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO 

----------------------------
 --  OneListItemDiscount 
----------------------------
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'OneListItemDiscount' and xtype='U')
    DROP TABLE [dbo].[OneListItemDiscount]
GO
CREATE TABLE [dbo].[OneListItemDiscount](
	[Id] uniqueidentifier NOT NULL, 
    [OneListId] uniqueidentifier NOT NULL, 
	[OneListItemId] uniqueidentifier NOT NULL,
    [LineNumber] int NOT NULL,
    [No] nvarchar(20) NOT NULL, 
	[DiscountType] int NOT NULL,
	[PeriodicDiscType] int NOT NULL,
	[PeriodicDiscGroup] nvarchar(20) NOT NULL,
	[Description] nvarchar(20) NOT NULL,
	[DiscountAmount] decimal(19, 8) NOT NULL,
	[DiscountPercent] decimal(19, 8) NOT NULL,
	[Quantity] decimal(19, 8) NOT NULL,
	[OfferNumber] nvarchar(20) NOT NULL,
    [CreateDate] datetime NOT NULL DEFAULT getdate(),
PRIMARY KEY NONCLUSTERED 
( [Id] ASC) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
) ON [PRIMARY] 
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[OneListItemDiscount]') AND name = N'IX_Id_OneListItemDiscount')
CREATE NONCLUSTERED INDEX [IX_Id_OneListItemDiscount] ON [dbo].[OneListItemDiscount] 
(
    [OneListId],[OneListItemId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

----------------------------
 --  Images
----------------------------
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'Images' and xtype='U')
    DROP TABLE [dbo].[Images]
GO
CREATE TABLE [dbo].[Images](
    [Id] nvarchar(50) NOT NULL,
    [Image] [image] NULL,
    [Type] int NOT NULL, --file=0, blob=1, url=2
    [Location] nvarchar(300) NOT NULL,
    [LastDateModified] datetime NOT NULL default getdate(),
PRIMARY KEY NONCLUSTERED 
( [Id]  ASC) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
) ON [PRIMARY] 
GO

----------------------------
 --  ImageLink
----------------------------
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'ImageLink' and xtype='U')
    DROP TABLE [dbo].[ImageLink]
GO
CREATE TABLE [dbo].[ImageLink](
    [TableName] nvarchar(50) NOT NULL,
    [RecordId] nvarchar(250) NOT NULL,
    [KeyValue] nvarchar(250) NOT NULL,
    [ImageId] nvarchar(50) NOT NULL,
    [DisplayOrder] int NOT NULL,
    [CreatedDate] datetime NULL default getdate(),
PRIMARY KEY NONCLUSTERED 
( [TableName],[KeyValue],[ImageId]  ASC) 
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
) ON [PRIMARY] 
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ImageLink]') AND name = N'IX_ImageId_ImageLink')
CREATE NONCLUSTERED INDEX [IX_ImageId_MemberTrigger] ON [dbo].[ImageLink] 
(
    [ImageId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

----------------------------
 -- LicenseActivity
---------------------------- 
IF  EXISTS (SELECT * FROM sysobjects WHERE name = N'LicenseActivity' and xtype='U')
DROP TABLE [dbo].[LicenseActivity]
GO
CREATE TABLE [dbo].[LicenseActivity](
    [Id] nvarchar(50) NOT NULL,
    [Counter] int NOT NULL,
    [Action] nvarchar(100) NOT NULL,
    [Created] datetime NOT NULL DEFAULT (getdate()),
    [LastModified] datetime NOT NULL DEFAULT (getdate()),
CONSTRAINT [PK_LicenseActivity] PRIMARY KEY NONCLUSTERED  
( 	[Id] ASC) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)  
) ON [PRIMARY] 
go
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[LicenseActivity]') AND name = N'IX_LastModified_LicenseActivity')
CREATE NONCLUSTERED INDEX [IX_LastModified_LicenseActivity] ON [dbo].[LicenseActivity] 
(
    [LastModified] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

----------------------------
 -- ResetPassword
---------------------------- 
IF  EXISTS (SELECT * FROM sysobjects WHERE name = N'ResetPassword' and xtype='U')
DROP TABLE [dbo].[ResetPassword]
GO
CREATE TABLE [dbo].[ResetPassword](
    [ResetCode] nvarchar(100) NOT NULL,
    [ContactId] nvarchar(20) NOT NULL,
    [Email] nvarchar(200) NOT NULL,
    [Enabled] bit NOT NULL,
    [Created] datetime NULL ,
CONSTRAINT [PK_ResetPassword] PRIMARY KEY NONCLUSTERED  
( [ResetCode] ASC) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)  
) ON [PRIMARY] 
go
 
----------------------------
 -- AppSettings
----------------------------
IF EXISTS(SELECT * FROM sysobjects WHERE name = N'AppSettings' and xtype='U')
    DROP TABLE [dbo].[AppSettings]
go
CREATE TABLE [AppSettings](
    [Key] nvarchar(100) NOT NULL,
    [LanguageCode] nvarchar(10) NOT NULL,
    [Value] nvarchar(4000) NOT NULL,
    [Comment] nvarchar(1000) NULL,  --about what goes into this field. This never goes to client
    [DataType] nvarchar(10) NOT NULL,  -- JIJ v2.0 added this new col
 CONSTRAINT PK_AppSettings PRIMARY KEY([Key],[LanguageCode]) );
 GO

----------------------------
 -- ImagesSizeCache.
----------------------------
IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ImagesSizeCache]') and type='U')
    DROP TABLE [dbo].[ImagesSizeCache]
go
CREATE TABLE [dbo].[ImagesSizeCache](
    [ImageId] nvarchar(50) NOT NULL,
    [Width] int NOT NULL,
    [Height] int NOT NULL,
    [Base64] [varchar](MAX) NOT NULL,
    [URL] nvarchar(500) NOT NULL,
    [Format] nvarchar(10)  NULL,
    [CreatedDate] datetime NOT NULL DEFAULT (getdate()) ,
    [LastModifiedDate] datetime NOT NULL DEFAULT (getdate()) ,
    [RV] rowversion NOT NULL,
 CONSTRAINT [PK_ImageSizeCache] PRIMARY KEY NONCLUSTERED 
(
    [ImageId] ASC,
    [Width] ASC,
    [Height] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] 
GO

----------------------------
 -- ImagesCache.
----------------------------
IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ImagesCache]') and type='U')
    DROP TABLE [dbo].[ImagesCache]
go
-- [image] has null, easer to insert in sql mgt studio
CREATE TABLE [dbo].[ImagesCache](
    [Id] nvarchar(50) NOT NULL ,
    [Width] int NOT NULL,
    [Height] int NOT NULL,
    [AvgColor] nvarchar(10) NOT NULL,
    [Format] nvarchar(10)  NULL,
    [CreatedDate] datetime NOT NULL DEFAULT (getdate()) ,
    [LastModifiedDate] datetime NOT NULL DEFAULT (getdate()) ,
    [Description] nvarchar(300)  NULL,
    [RV] rowversion NOT NULL,
 CONSTRAINT [PK_ImagesCache] PRIMARY KEY NONCLUSTERED 
(
    [Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] 
GO

----------------------------
 -- MenuCache.
----------------------------
IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MenuCache]') and type='U')
    DROP TABLE [dbo].[MenuCache]
GO
CREATE TABLE [dbo].[MenuCache](
    [Id] nvarchar(20) NOT NULL,
    [Version] nvarchar(10) NOT NULL,
    [XmlData] nvarchar(max) NOT NULL,
    [CreatedDate] datetime NOT NULL DEFAULT (getdate()) ,
    [LastModifiedDate] datetime NOT NULL DEFAULT (getdate()) ,
    [RV] [timestamp] NOT NULL,
 CONSTRAINT [PK_MenuCache] PRIMARY KEY NONCLUSTERED 
(
    [Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]  
GO

----------------------------
 -- OrderQueue.
----------------------------
IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OrderQueue]') and type='U')
    DROP TABLE [dbo].[OrderQueue]
GO
-- OrderStatus in (0,1,2,3)  New=0, InProcess=1, Failed=2, Processed=3
-- OrderType in (0,1)  QSR=0, ClickCollect=1 
-- statusChange is simply a text about what changed !   
--    [0 2014-05-26 11:21:09] || [1 2014-05-26 11:22:19] || [3 2014-05-26 11:22:48] 
CREATE TABLE [dbo].[OrderQueue](
    [Guid] uniqueidentifier NOT NULL , 
    [Id] [bigint] IDENTITY(1,1) NOT NULL,
    [OrderStatus] int NOT NULL DEFAULT (0) CHECK (OrderStatus in (0,1,2,3)),
    [OrderType] int NOT NULL DEFAULT (0)  CHECK (OrderType in (0,1)),  --new clickcollect -- JIJ v2.0 added this new col
    [OrderXml] nvarchar(max) NOT NULL DEFAULT ('') ,
    [DateCreated] datetime NOT NULL DEFAULT (getdate()) ,
    [DateLastModified] datetime NOT NULL DEFAULT (getdate()) ,
    [Description] nvarchar(1000) NOT NULL DEFAULT ('') ,
    [PhoneNumber] nvarchar(20) NULL DEFAULT ('') , 
    [Email] nvarchar(250) NULL DEFAULT ('') ,     -- JIJ v2.0 added this new col  
    [SearchKey] nvarchar(100) NOT NULL DEFAULT ('') ,    --Any key you want to searchby. new clickcollect -- JIJ v2.0 added this new col
    [ContactId] nvarchar(50) NOT NULL DEFAULT ('') ,
    [DeviceId] nvarchar(100) NOT NULL DEFAULT ('') ,
    [StoreId] nvarchar(50) NOT NULL DEFAULT ('') ,
    [TerminalId] nvarchar(50) NOT NULL DEFAULT ('') ,
    [StatusChange] nvarchar(1000) NOT NULL DEFAULT ('') ,
    [RV] rowversion NOT NULL,
 CONSTRAINT [PK_OrderQueue] PRIMARY KEY CLUSTERED 
(
    [Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] 
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[OrderQueue]') AND name = N'IX_OrderQueue_DateCreated')
CREATE NONCLUSTERED INDEX [IX_OrderQueue_DateCreated] ON [dbo].[OrderQueue] 
(
    [DateCreated] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[OrderQueue]') AND name = N'IX_OrderQueue_SearchKey')
CREATE NONCLUSTERED INDEX [IX_OrderQueue_SearchKey] ON [dbo].[OrderQueue] 
(
    [SearchKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[OrderQueue]') AND name = N'IX_ORDERQUEUE_Guid')
CREATE UNIQUE NONCLUSTERED INDEX [IX_ORDERQUEUE_Guid] ON [dbo].[OrderQueue]
(
    [Guid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO 

----------------------------
 -- OrderMessage
----------------------------
IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OrderMessage]') and type='U')
    DROP TABLE [dbo].OrderMessage
GO
-- MessageStatus in (0,1,2,3)  New=0, InProcess=1, Failed=2, Processed=3
CREATE TABLE [dbo].OrderMessage(
    [Guid] uniqueidentifier NOT NULL , 
    [Id] [bigint] IDENTITY(1,1) NOT NULL,
    [MessageStatus] int NOT NULL DEFAULT (0)  CHECK (MessageStatus in (0,1,2,3)),
    [Description] nvarchar(2000) NOT NULL DEFAULT ('') ,
    [Details] nvarchar(max) NOT NULL DEFAULT ('') ,
    [DateCreated] datetime NOT NULL DEFAULT (getdate()) ,
    [DateLastModified] datetime NOT NULL DEFAULT (getdate()) ,
    [RV] rowversion NOT NULL,
 CONSTRAINT [PK_OrderMessage] PRIMARY KEY CLUSTERED 
(
    [Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] 
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[OrderMessage]') AND name = N'IX_ORDERMESSAGE_Guid')
CREATE NONCLUSTERED INDEX [IX_ORDERMESSAGE_Guid] ON [dbo].[OrderMessage]
(
    [Guid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO 
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[OrderMessage]') AND name = N'IX_ORDERMESSAGE_DateCreated')
CREATE NONCLUSTERED INDEX [IX_ORDERMESSAGE_DateCreated] ON [dbo].[OrderMessage] 
(
    [DateCreated] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

----------------------------
 -- EmailMessage
----------------------------
IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EmailMessage]') and type='U')
    DROP TABLE [dbo].EmailMessage
GO
-- EmailStatus in (0,1,2,3,4)  New=0, InProcess=1, Failed=2, Processed=3, RetryLater=4
-- EmailType, Unknown= 0 OrderMessage=1, ResetEmail=2,  EmailReceipt=3
CREATE TABLE [dbo].EmailMessage(
    [Guid] uniqueidentifier NOT NULL , 
    [EmailTo] nvarchar(1000) NOT NULL DEFAULT ('') ,
    [EmailCc] nvarchar(1000) NOT NULL DEFAULT ('') ,
    [EmailFrom] nvarchar(100) NOT NULL DEFAULT ('') ,
    [EmailStatus] int NOT NULL DEFAULT (0)  CHECK (EmailStatus in (0,1,2,3,4)),
    [EmailType] int NOT NULL DEFAULT (0)  ,
    [Subject] nvarchar(500) NOT NULL DEFAULT ('') ,
    [Body] nvarchar(max) NOT NULL DEFAULT ('') ,
	[Attachments] nvarchar(500) NOT NULL DEFAULT ('') ,
    [Error] nvarchar(4000) NOT NULL DEFAULT ('') ,
    [RetryCounter] int NOT NULL DEFAULT (0) ,
    [ExternalId] nvarchar(50) NOT NULL DEFAULT ('') ,  --link to other table
    [DateCreated] datetime NOT NULL DEFAULT (getdate()) ,
    [DateLastModified] datetime NOT NULL DEFAULT (getdate()) ,
 CONSTRAINT [PK_EmailMessage] PRIMARY KEY CLUSTERED 
(
    [Guid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] 
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[EmailMessage]') AND name = N'IX_EmailMessage_DateCreated')
CREATE NONCLUSTERED INDEX [IX_EmailMessage_DateCreated] ON [dbo].[EmailMessage] 
(
    [DateCreated] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

----------------------------
 -- Disclaimer
----------------------------
IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Disclaimer]') and type='U')
    DROP TABLE [dbo].Disclaimer
GO
CREATE TABLE [dbo].Disclaimer(
    [Code] nvarchar(20) NOT NULL DEFAULT ('') ,
    [Personalized] bit NOT NULL DEFAULT (0) ,
    [Disclaimer] nvarchar(500) NOT NULL DEFAULT ('') ,
    [DateCreated] datetime NULL DEFAULT (getdate()) ,
 CONSTRAINT [PK_Disclaimer] PRIMARY KEY CLUSTERED 
(
    [Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] 
GO

----------------------------
 -- ActivityLog
---------------------------- 
IF  EXISTS (SELECT * FROM sysobjects WHERE name = N'ActivityLog' and xtype='U')
DROP TABLE [dbo].[ActivityLog]
GO
CREATE TABLE [dbo].[ActivityLog](
    [Id] uniqueidentifier NOT NULL DEFAULT(NEWSEQUENTIALID()),
    [Solution] [varchar](2) NOT NULL,  -- LR(retail loy), LH(hosploy), PR(retailPOS), PH(hospPOS) , EC(ecomm), IN(inventory)
    --type: IG(item group), PG(prodgroup) IT(em),SE(earch),CO(upon),OF(fer),NO(tification),LI(login),LO(goff),CT(contact use),CC(clickcoll),SO(sales order), ST(ore), TR(ansHist)
    [Type] [varchar](2) NOT NULL,      
    [TypeValue] nvarchar(50) NOT NULL,
    [ContactId] nvarchar(50) NULL,  
    [DeviceId] nvarchar(50) NOT NULL,
    [IPAddress] nvarchar(50) NOT NULL,  --ipv6 can be 45 
    [DateCreated] datetime NOT NULL DEFAULT (SYSDATETIME()),   -- datetime when log was created
CONSTRAINT [PK_ActivityLog] PRIMARY KEY NONCLUSTERED  
( [Id] ASC) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)  
) ON [PRIMARY] 
 
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ActivityLog]') AND name = N'IX_DateCreated_ActivityLog')
CREATE NONCLUSTERED INDEX [IX_DateCreated_ActivityLog] ON [dbo].[ActivityLog] 
(
    [DateCreated] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

----------------------------
 -- Task Tables for OmniTasks
---------------------------- 
IF  EXISTS (SELECT * FROM sysobjects WHERE name = N'Task' and xtype='U')
DROP TABLE [dbo].[Task] 
GO
CREATE TABLE [dbo].[Task](
	[Id] nvarchar(40) NOT NULL,
	[Status] nvarchar(20) NULL,
	[Type] nvarchar(20) NULL,
	[TransactionId] nvarchar(30) NULL,
	[CreateTime] datetime NOT NULL,
	[ModifyTime] datetime NOT NULL,
	[ModifyUser] nvarchar(30) NULL,
	[ModifyLocation] nvarchar(30) NULL,
	[StoreId] nvarchar(30) NULL,
	[RequestUser] nvarchar(30) NULL,
	[RequestUserName] nvarchar(30) NULL,
	[RequestLocation] nvarchar(30) NULL,
	[AssignUser] nvarchar(30) NULL,
	[AssignUserName] nvarchar(30) NULL,
	[AssignLocation] nvarchar(30) NULL,
 CONSTRAINT [PK_Task] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
 
IF  EXISTS (SELECT * FROM sysobjects WHERE name = N'TaskLine' and xtype='U')
DROP TABLE [dbo].[TaskLine] 
GO
CREATE TABLE [dbo].[TaskLine](
	[Id] nvarchar(40) NOT NULL,
	[TaskId] nvarchar(40) NOT NULL,
	[LineNumber] int NOT NULL,
	[Status] nvarchar(20) NULL,
	[ModifyTime] datetime NOT NULL,
	[ModifyUser] nvarchar(30) NULL,
	[ModifyLocation] nvarchar(30) NULL,
	[ItemId] nvarchar(30) NULL,
	[ItemName] nvarchar(50) NULL,
	[VariantId] nvarchar(30) NULL,
	[VariantName] nvarchar(150) NULL,
	[Quantity] int NOT NULL,
 CONSTRAINT [PK_TaskLine] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE name = N'TaskLog' and xtype='U')
DROP TABLE [dbo].[TaskLog] 
GO
CREATE TABLE [dbo].[TaskLog](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[TaskId] nvarchar(40) NOT NULL,
	[ModifyTime] datetime NOT NULL,
	[ModifyUser] nvarchar(30) NULL,
	[ModifyLocation] nvarchar(30) NULL,
	[StatusFrom] nvarchar(20) NULL,
	[StatusTo] nvarchar(20) NULL,
	[RequestUserFrom] nvarchar(30) NULL,
	[RequestUserTo] nvarchar(30) NULL,
	[AssignUserFrom] nvarchar(30) NULL,
	[AssignUserTo] nvarchar(30) NULL,
 CONSTRAINT [PK_TaskLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE name = N'TaskLogLine' and xtype='U')
DROP TABLE [dbo].[TaskLogLine] 
GO
CREATE TABLE [dbo].[TaskLogLine](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[TaskLineId] nvarchar(40) NOT NULL,
	[ModifyTime] datetime NOT NULL,
	[ModifyUser] nvarchar(30) NULL,
	[ModifyLocation] nvarchar(30) NULL,
	[StatusFrom] nvarchar(20) NULL,
	[StatusTo] nvarchar(20) NULL,
 CONSTRAINT [PK_TaskLogLine] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

----------------------------
 -- PayRequest buffer to confirm payment requests to ECom
---------------------------- 
IF  EXISTS (SELECT * FROM sysobjects WHERE name = N'PayRequests' and xtype='U')
DROP TABLE [dbo].[PayRequests]
GO
CREATE TABLE [dbo].[PayRequests](
	[Id] uniqueidentifier NOT NULL,
	[OrderId] nvarchar(30) NULL,
	[RegTime] datetime NULL,
 CONSTRAINT [PK_PayRequests] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[PayRequests]') AND name = N'IX_PayRequest_Time')
CREATE NONCLUSTERED INDEX [IX_PayRequest_Time] ON [dbo].[PayRequests]
(
	[RegTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

----------------------------------------------------------------------------------------------------------------
-- TRIGGERS ------------------------------
---------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trOneList]'))
DROP TRIGGER [dbo].[trOneList]
GO
CREATE TRIGGER [dbo].[trOneList]
   ON [dbo].[OneList] FOR INSERT, UPDATE
 AS
    SET NOCOUNT ON;
    -- ENFORCE that a contact has only one current list
    declare @cnt int
              
    select @cnt = COUNT(distinct ol.Id) FROM Inserted i
          INNER JOIN OneList ol ON i.ContactId = ol.ContactId and ol.IsDefaultList = 1 and i.ListType = ol.ListType
    IF (@cnt > 1)
    BEGIN
        RAISERROR('OneList.IsDefaultList is already set for this contact and listtype',16,1)
        ROLLBACK TRAN
    END
GO  

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trOneListBasket]'))
DROP TRIGGER [dbo].[trOneListBasket]
GO
CREATE TRIGGER [dbo].[trOneListBasket]
   ON [dbo].[OneList] FOR INSERT, UPDATE
 AS
    SET NOCOUNT ON;
    -- ENFORCE that a contact has only one current list
    declare @cnt int
    declare @cid nvarchar(30)
              
    select @cnt = COUNT(distinct ol.Id) FROM Inserted i
        INNER JOIN OneList ol ON i.ContactId = ol.ContactId and ol.ListType = 0

    select @cid = i.ContactId FROM Inserted i

    IF (@cnt > 1 AND @cid <> '')
    BEGIN
        RAISERROR('OneList.ListType = 0 (basket) can only have one list',16,1)
        ROLLBACK TRAN
    END
GO  
-- 
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[AppSettingsTrg]'))
DROP TRIGGER [dbo].[AppSettingsTrg]
GO
CREATE TRIGGER [dbo].[AppSettingsTrg]
   ON [dbo].[AppSettings] AFTER INSERT, UPDATE
 AS
    SET NOCOUNT ON;
    BEGIN
    if exists (select * from inserted where [DataType] not in ('string','int','bool','decimal') )
    begin
        RAISERROR('AppSettings.DataType must either String, Int, Bool or Decimal',16,1)
        ROLLBACK TRAN
    end

    --not perfect!  breaks in a batch but better than nothing at all 
    DECLARE @value nvarchar(4000)
    DECLARE @datatype nvarchar(10)
    select @value = [Value], @datatype = [DataType] FROM inserted
    if (@datatype = 'int' and ISNUMERIC(@value) != 1)
        begin
        RAISERROR('AppSettings.Value must be an integer',16,1)
        ROLLBACK TRAN
    end
    if (@datatype = 'decimal' and ISNUMERIC(@value) != 1)
        begin
        RAISERROR('AppSettings.Value must be a decimal',16,1)
        ROLLBACK TRAN
    end
    if (@datatype = 'bool' and not(@value = 'true' or @value = 'false' ))
        begin
        RAISERROR('AppSettings.Value must be true or false',16,1)
        ROLLBACK TRAN
    end

   END
GO 

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[ImagesTrg]'))
DROP TRIGGER [dbo].[ImagesTrg]
GO
CREATE TRIGGER [dbo].[ImagesTrg]
   ON [dbo].[Images] AFTER INSERT, UPDATE, DELETE
 AS
    SET NOCOUNT ON;
    --Determine if this is an INSERT,UPDATE, or DELETE Action or a "failed delete".
    DECLARE @Action as char(1);
    SET @Action = (CASE WHEN EXISTS(SELECT * FROM INSERTED)
                         AND EXISTS(SELECT * FROM DELETED)
                        THEN 'U'  -- Set Action to Updated.
                        WHEN EXISTS(SELECT * FROM INSERTED)
                        THEN 'I'  -- Set Action to Insert.
                        WHEN EXISTS(SELECT * FROM DELETED)
                        THEN 'D'  -- Set Action to Deleted.
                        ELSE NULL -- Skip. It may have been a "failed delete".   
                    END)
   -- always clean up the cache tables, no matter what..
   if (@Action in ('D','U'))
   begin
        Delete from ImagesCache
        FROM ImagesCache h
            INNER JOIN Deleted d ON h.Id = d.Id 

        Delete from ImagesSizeCache
        FROM ImagesSizeCache h
            INNER JOIN Deleted d ON d.Id = h.ImageId 
   end
   if (@Action = 'I')
   begin
        Delete from ImagesCache
        FROM ImagesCache h
            INNER JOIN Inserted d ON h.Id = d.Id 

        Delete from ImagesSizeCache
        FROM ImagesSizeCache h
            INNER JOIN Inserted d ON d.Id = h.ImageId 
   end
GO    

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[ImagesCacheTrg]'))
DROP TRIGGER [dbo].[ImagesCacheTrg]
GO
CREATE TRIGGER [dbo].[ImagesCacheTrg]
   ON [dbo].[ImagesCache] AFTER  UPDATE, DELETE
 AS
    SET NOCOUNT ON;
    --Determine if this is an INSERT,UPDATE, or DELETE Action or a "failed delete".
    DECLARE @Action as char(1);
    SET @Action = (CASE WHEN EXISTS(SELECT * FROM INSERTED)
                         AND EXISTS(SELECT * FROM DELETED)
                        THEN 'U'  -- Set Action to Updated.
                        WHEN EXISTS(SELECT * FROM INSERTED)
                        THEN 'I'  -- Set Action to Insert.
                        WHEN EXISTS(SELECT * FROM DELETED)
                        THEN 'D'  -- Set Action to Deleted.
                        ELSE NULL -- Skip. It may have been a "failed delete".   
                    END)
   -- always clean up the cache tables, no matter what..
   if (@Action in ('U', 'D'))
   begin
        Delete from ImagesSizeCache
        FROM ImagesSizeCache h
            INNER JOIN Deleted d ON d.Id = h.ImageId 
   end

GO    

