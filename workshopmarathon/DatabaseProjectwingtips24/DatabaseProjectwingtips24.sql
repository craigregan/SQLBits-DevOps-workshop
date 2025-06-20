CREATE TABLE [dbo].[VenueTypes] (
    [VenueType]                NVARCHAR (30) NOT NULL,
    [VenueTypeName]            NVARCHAR (30) NOT NULL,
    [EventTypeName]            NVARCHAR (30) NOT NULL,
    [EventTypeShortName]       NVARCHAR (20) NOT NULL,
    [EventTypeShortNamePlural] NVARCHAR (20) NOT NULL,
    [Language]                 NVARCHAR (10) NOT NULL,
    PRIMARY KEY CLUSTERED ([VenueType] ASC),
    CONSTRAINT [AK_VenueType_VenueTypeName_Language] UNIQUE NONCLUSTERED ([VenueTypeName] ASC, [Language] ASC)
);


GO

CREATE TABLE [dbo].[Events] (
    [VenueId]    INT           NOT NULL,
    [EventId]    INT           IDENTITY (1, 1) NOT NULL,
    [EventName]  NVARCHAR (50) NOT NULL,
    [Subtitle]   NVARCHAR (50) NULL,
    [Date]       DATETIME      NOT NULL,
    [RowVersion] ROWVERSION    NOT NULL,
    PRIMARY KEY CLUSTERED ([VenueId] ASC, [EventId] ASC),
    CONSTRAINT [FK_Events_Venues] FOREIGN KEY ([VenueId]) REFERENCES [dbo].[Venues] ([VenueId])
);


GO

CREATE TABLE [dbo].[Sections] (
    [VenueId]       INT           NOT NULL,
    [SectionId]     INT           IDENTITY (1, 1) NOT NULL,
    [SectionName]   NVARCHAR (30) NOT NULL,
    [SeatRows]      SMALLINT      DEFAULT ((20)) NOT NULL,
    [SeatsPerRow]   SMALLINT      DEFAULT ((30)) NOT NULL,
    [StandardPrice] MONEY         DEFAULT ((10)) NOT NULL,
    [RowVersion]    ROWVERSION    NOT NULL,
    PRIMARY KEY CLUSTERED ([VenueId] ASC, [SectionId] ASC),
    CONSTRAINT [CK_Sections_SeatRows] CHECK ([SeatRows]<=(1000) AND [SeatRows]>(0)),
    CONSTRAINT [CK_Sections_SeatsPerRow] CHECK ([SeatsPerRow]<=(1000) AND [SeatsPerRow]>(0)),
    CONSTRAINT [CK_Sections_StandardPrice] CHECK ([StandardPrice]<=(100000)),
    CONSTRAINT [FK_Sections_Venues] FOREIGN KEY ([VenueId]) REFERENCES [dbo].[Venues] ([VenueId])
);


GO

CREATE TABLE [dbo].[Tickets] (
    [VenueId]          INT NOT NULL,
    [TicketId]         INT IDENTITY (1, 1) NOT NULL,
    [RowNumber]        INT NOT NULL,
    [SeatNumber]       INT NOT NULL,
    [EventId]          INT NOT NULL,
    [SectionId]        INT NOT NULL,
    [TicketPurchaseId] INT NOT NULL,
    PRIMARY KEY CLUSTERED ([VenueId] ASC, [TicketId] ASC),
    CONSTRAINT [FK_Tickets_EventSections] FOREIGN KEY ([VenueId], [EventId], [SectionId]) REFERENCES [dbo].[EventSections] ([VenueId], [EventId], [SectionId]),
    CONSTRAINT [FK_Tickets_TicketPurchases] FOREIGN KEY ([VenueId], [TicketPurchaseId]) REFERENCES [dbo].[TicketPurchases] ([VenueId], [TicketPurchaseId]) ON DELETE CASCADE,
    CONSTRAINT [AK_Venue_Event_Seat_Ticket] UNIQUE NONCLUSTERED ([VenueId] ASC, [EventId] ASC, [SectionId] ASC, [RowNumber] ASC, [SeatNumber] ASC)
);


GO

CREATE TABLE [dbo].[Customers] (
    [VenueId]     INT           NOT NULL,
    [CustomerId]  INT           IDENTITY (1, 1) NOT NULL,
    [FirstName]   NVARCHAR (50) NOT NULL,
    [LastName]    NVARCHAR (50) NOT NULL,
    [Email]       VARCHAR (128) NOT NULL,
    [Password]    NVARCHAR (30) NULL,
    [PostalCode]  NVARCHAR (20) NULL,
    [CountryCode] CHAR (3)      NOT NULL,
    [RowVersion]  ROWVERSION    NOT NULL,
    PRIMARY KEY CLUSTERED ([VenueId] ASC, [CustomerId] ASC),
    CONSTRAINT [FK_Customers_Countries] FOREIGN KEY ([CountryCode]) REFERENCES [dbo].[Countries] ([CountryCode]),
    CONSTRAINT [FK_Customers_Venues] FOREIGN KEY ([VenueId]) REFERENCES [dbo].[Venues] ([VenueId]),
    CONSTRAINT [AK_Venue_Email] UNIQUE NONCLUSTERED ([VenueId] ASC, [Email] ASC)
);


GO

CREATE TABLE [dbo].[Venues] (
    [VenueId]       INT            NOT NULL,
    [VenueName]     NVARCHAR (50)  NOT NULL,
    [VenueType]     NVARCHAR (30)  NOT NULL,
    [AdminEmail]    NVARCHAR (128) NOT NULL,
    [AdminPassword] NVARCHAR (30)  NULL,
    [PostalCode]    NVARCHAR (20)  NULL,
    [CountryCode]   CHAR (3)       NOT NULL,
    [RowVersion]    ROWVERSION     NOT NULL,
    CONSTRAINT [PK_Venues] PRIMARY KEY CLUSTERED ([VenueId] ASC),
    CONSTRAINT [FK_Venues_Countries] FOREIGN KEY ([CountryCode]) REFERENCES [dbo].[Countries] ([CountryCode]),
    CONSTRAINT [FK_Venues_VenueTypes] FOREIGN KEY ([VenueType]) REFERENCES [dbo].[VenueTypes] ([VenueType])
);


GO

CREATE TABLE [dbo].[EventSections] (
    [VenueId]    INT        NOT NULL,
    [EventId]    INT        NOT NULL,
    [SectionId]  INT        NOT NULL,
    [Price]      MONEY      NOT NULL,
    [RowVersion] ROWVERSION NULL,
    PRIMARY KEY CLUSTERED ([VenueId] ASC, [EventId] ASC, [SectionId] ASC),
    CONSTRAINT [FK_EventSections_Events] FOREIGN KEY ([VenueId], [EventId]) REFERENCES [dbo].[Events] ([VenueId], [EventId]) ON DELETE CASCADE,
    CONSTRAINT [FK_EventSections_Sections] FOREIGN KEY ([VenueId], [SectionId]) REFERENCES [dbo].[Sections] ([VenueId], [SectionId])
);


GO

CREATE TABLE [dbo].[TicketPurchases] (
    [VenueId]          INT        NOT NULL,
    [TicketPurchaseId] INT        IDENTITY (1, 1) NOT NULL,
    [PurchaseDate]     DATETIME   NOT NULL,
    [PurchaseTotal]    MONEY      NOT NULL,
    [CustomerId]       INT        NOT NULL,
    [RowVersion]       ROWVERSION NOT NULL,
    PRIMARY KEY CLUSTERED ([VenueId] ASC, [TicketPurchaseId] ASC),
    CONSTRAINT [FK_TicketPurchases_Customers] FOREIGN KEY ([VenueId], [CustomerId]) REFERENCES [dbo].[Customers] ([VenueId], [CustomerId])
);


GO

CREATE TABLE [dbo].[Countries] (
    [CountryCode] CHAR (3)      NOT NULL,
    [CountryName] NVARCHAR (50) NOT NULL,
    [Language]    NVARCHAR (10) DEFAULT ('en') NOT NULL,
    PRIMARY KEY CLUSTERED ([CountryCode] ASC)
);


GO

CREATE VIEW [dbo].[TicketFacts] AS
SELECT      v.VenueId, v.VenueName, v.VenueType,v.PostalCode as VenuePostalCode,  
            (SELECT SUM (SeatRows * SeatsPerRow) FROM [dbo].[Sections] WHERE VenueId = v.VenueId) AS VenueCapacity,
            tp.TicketPurchaseId, tp.PurchaseDate, tp.PurchaseTotal,
            t.RowNumber, t.SeatNumber, 
            c.CustomerId, c.PostalCode AS CustomerPostalCode, c.CountryCode, Convert(int, HASHBYTES('md5',c.Email)) AS CustomerEmailId, 
            e.EventId, e.EventName, e.Subtitle AS EventSubtitle, e.Date AS EventDate
    FROM    [dbo].[Venues] as v
            INNER JOIN [dbo].[TicketPurchases] AS tp ON tp.VenueId = v.VenueId
            INNER JOIN [dbo].[Tickets] AS t ON t.TicketPurchaseId = tp.TicketPurchaseId AND t.VenueId = v.VenueId
            INNER JOIN [dbo].[Events] AS e ON t.EventId = e.EventId AND e.VenueId = v.VenueId
            INNER JOIN [dbo].[Customers] AS c ON tp.CustomerId = c.CustomerId AND c.VenueId = v.VenueId

GO

CREATE VIEW [dbo].[EventsWithNoTickets]
    AS SELECT VenueId, EventId, EventName, Subtitle, Date from dbo.Events as e
    WHERE (SELECT Count(*) FROM dbo.Tickets AS t WHERE t.EventId=e.EventId and t.VenueId = e.VenueId) = 0

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Countries_Country_Language]
    ON [dbo].[Countries]([CountryCode] ASC, [Language] ASC);


GO

CREATE USER [student]
    WITH PASSWORD = N'gexpwuctf|V{s|grzzxJa;pnmsFT7_&#$!~<ckdwZ{vmsluo';


GO

ALTER ROLE [db_owner] ADD MEMBER [student];


GO

CREATE PROCEDURE [dbo].[DeleteVenue]
    @VenueId int = 0
AS
    IF @VenueId IS NULL
    BEGIN
        RAISERROR ('Error. @VenueId must be specified', 11, 1)
        RETURN 1
    END
        
    DELETE [dbo].[Tickets] WHERE VenueId = @VenueId
    
    DELETE [dbo].[TicketPurchases] WHERE VenueId = @VenueId
    
    DELETE [dbo].[Customers] WHERE VenueId = @VenueId
    
    DELETE [dbo].[EventSections] WHERE VenueId = @VenueId
    
    DELETE [dbo].[Sections] WHERE VenueId = @VenueId
    
    DELETE [dbo].[Events] WHERE VenueId = @VenueId
    
    DELETE [dbo].[Venues] WHERE VenueId = @VenueId

RETURN 0

GO

CREATE PROCEDURE [dbo].[DeleteEvent]
	@VenueId int,
    @EventId int
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @Tickets int = (SELECT Count(*) FROM dbo.Tickets WHERE VenueId = @VenueId AND EventId = @EventId)

    IF @Tickets > 0
    BEGIN
        RAISERROR ('Error. Cannot delete event for which tickets have been purchased.', 11, 1)
        RETURN 1
    END

    DELETE FROM dbo.[EventSections]
    WHERE VenueId = @VenueId AND EventId = @EventId

    DELETE FROM dbo.[Events]
    WHERE VenueId = @VenueId AND EventId = @EventId

    RETURN 0
END

GO

CREATE PROCEDURE [dbo].[ResetEventDates]
    @StartHour int = 19,
    @StartMinute int = 00
AS
    SET NOCOUNT ON

    DECLARE @VenueId int
    DECLARE @EventId int
    DECLARE @Offset int   
    DECLARE @Interval int = 3   -- interval in days between each event
    DECLARE @OldEventDate datetime
    DECLARE @NewEventDate datetime
    DECLARE @Diff int
    DECLARE @BaseDate datetime = DATETIMEFROMPARTS(YEAR(CURRENT_TIMESTAMP),MONTH(CURRENT_TIMESTAMP),DAY(CURRENT_TIMESTAMP),@StartHour,@StartMinute,00,000)
    DECLARE VenueCursor CURSOR FOR SELECT VenueId FROM [dbo].[Venues]

    OPEN VenueCursor
    FETCH NEXT FROM VenueCursor INTO @VenueId 

    WHILE @@Fetch_Status = 0
    BEGIN
        SET @Offset = -5    -- offset of the first event in days from current date 
        DECLARE EventCursor CURSOR FOR SELECT EventId FROM [dbo].[Events] WHERE VenueId = @VenueId 
        OPEN EventCursor
        FETCH NEXT FROM EventCursor INTO @EventId
        --
        WHILE @@Fetch_Status = 0
        BEGIN
            SET @OldEventDate = (SELECT top 1 [Date] from [Events] WHERE VenueId = @VenueId AND EventId=@EventId)
            SET @NewEventDate = DATEADD(Day,@Offset,@BaseDate)
        
            UPDATE [Events] SET [Date] = @NewEventDate WHERE VenueId = @VenueId AND EventId=@EventId 
        
            UPDATE TicketPurchases SET PurchaseDate = DATEADD(day,Diff,@NewEventDate) 
            FROM TicketPurchases AS tp
            INNER JOIN (SELECT tp2.TicketPurchaseId, DATEDIFF(day,@OldEventDate,tp2.PurchaseDate) AS Diff 
                            FROM TicketPurchases AS tp2
                            INNER JOIN [Tickets] AS t ON t.TicketPurchaseId = tp2.TicketPurchaseId
                            INNER JOIN [Events] AS e ON t.EventId = e.EventId
                        WHERE e.VenueId = @VenueId AND e.EventId = @EventId) AS etp ON etp.TicketPurchaseId = tp.TicketPurchaseId

            SET @Offset = @Offset + @Interval
            --get next event
	        FETCH NEXT FROM EventCursor INTO @EventId

        END    
        CLOSE EventCursor
        DEALLOCATE EventCursor
        -- get next venue 
        FETCH NEXT FROM VenueCursor INTO @VenueId
                
    END

    CLOSE VenueCursor
    DEALLOCATE VenueCursor
    RETURN 0

GO

