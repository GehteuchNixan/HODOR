--@author: Aaron

/*
**	0. Schema anlegen, wenn noch nicht vorhanden
*/
IF NOT EXISTS(SELECT * FROM sys.schemas WHERE name='gr1')
BEGIN
	--stupid schema creation needs his own batch... hack ahead:
	EXEC('CREATE SCHEMA gr1')
END

/*
**	1. Schritt des Scripts: Tabellen anlegen
*/

CREATE TABLE [gr1].Programm
(
	ProgrammID INT IDENTITY(1,1) NOT NULL,
	Name varchar(255) NOT NULL,

	CONSTRAINT PK_ProgrammID PRIMARY KEY (ProgrammID)
);

CREATE TABLE [gr1].Release
(
	ReleaseID INT IDENTITY(1,1) NOT NULL,
	ReleaseVonProgramm INT NOT NULL,
	Releasedatum DATE NOT NULL,
	Releasenummer INT NOT NULL,

	CONSTRAINT PK_ReleaseID PRIMARY KEY (ReleaseID),
	CONSTRAINT FK_Release_Von_Programm FOREIGN KEY (ReleaseVonProgramm) REFERENCES [gr1].Programm(ProgrammID) ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE TABLE [gr1].Subrelease
(
	ReleaseID INT NOT NULL,
	SubreleaseVonRelease INT NOT NULL,

	CONSTRAINT PK_SubreleaseID PRIMARY KEY (ReleaseID),
	CONSTRAINT FK_Subrelease_Zu_Release FOREIGN KEY (ReleaseID) REFERENCES [gr1].Release(ReleaseID) ON DELETE CASCADE ON UPDATE NO ACTION,
	CONSTRAINT FK_Subrelease_Zu_OberRelease FOREIGN KEY (SubreleaseVonRelease) REFERENCES [gr1].Release(ReleaseID)
);

CREATE TABLE [gr1].Build
(
	ReleaseID INT NOT NULL,
	BuildVonSubrelease INT NOT NULL,
	Datendateipfad varchar(255),

	CONSTRAINT PK_BuildID PRIMARY KEY (ReleaseID),
	CONSTRAINT FK_Build_Zu_Release FOREIGN KEY (ReleaseID) REFERENCES [gr1].Release(ReleaseID) ON DELETE CASCADE ON UPDATE NO ACTION,
	CONSTRAINT FK_Build_Zu_Oberrelease FOREIGN KEY (BuildVonSubrelease) REFERENCES [gr1].Subrelease(ReleaseID)
);

/*
** Matching Tabelle Modul(Programm)-->Subrelease
*/
CREATE TABLE [gr1].Modul_Zu_Subrelease
(
	ProgrammID INT NOT NULL,
	SubreleaseID INT NOT NULL,
	/*
	** Hier definiert ein Constraint den zusammengesetzten Prim�rschl�ssel
	*/
	CONSTRAINT PK_Modul_Zu_Subrelease PRIMARY KEY (ProgrammID, SubreleaseID),
	CONSTRAINT FK_MzS_Modul FOREIGN KEY (ProgrammID) REFERENCES [gr1].Programm(ProgrammID) ON DELETE CASCADE ON UPDATE NO ACTION,
	CONSTRAINT FK_MzD_Subrelease FOREIGN KEY (SubreleaseID) REFERENCES [gr1].Subrelease(ReleaseID)
);

CREATE TABLE [gr1].Rechte
(
	RechteID INT IDENTITY(1,1) NOT NULL,
	Beschreibung varchar(255),
	Name varchar(255),

	CONSTRAINT PK_RechteID PRIMARY KEY (RechteID)
);

CREATE TABLE [gr1].Rolle
(
	RolleID INT IDENTITY(1,1) NOT NULL,
	Rollenname varchar(255) NOT NULL,

	CONSTRAINT PK_RolleID PRIMARY KEY (RolleID)
);

CREATE TABLE [gr1].Benutzer
(
	BenutzerID INT IDENTITY(1,1) NOT NULL,
	NutzerNr varchar(255) NOT NULL,
	Email varchar(255) NOT NULL,
	Name varchar(255) NOT NULL,
	PasswortHash varchar(255),
	RolleID INT NOT NULL,

	CONSTRAINT PK_BenutzerID PRIMARY KEY (BenutzerID),
	CONSTRAINT FK_Rolle FOREIGN KEY (RolleID) REFERENCES [gr1].Rolle(RolleID)
);

/*
** Jetzt noch Rolle--> Rechte Matching Tabelle dazu...
*/
CREATE TABLE [gr1].Rolle_Zu_Rechte
(
	RolleID INT NOT NULL,
	RechteID INT NOT NULL,
	/*
	** Hier definiert ein Constraint den zusammengesetzten Prim�rschl�ssel
	*/
	CONSTRAINT PK_Rolle_Zu_Rechte PRIMARY KEY (RolleID,RechteID),

	CONSTRAINT FK_RzR_Rechte FOREIGN KEY (RechteID) REFERENCES [gr1].Rechte(RechteID) ON DELETE CASCADE ON UPDATE NO ACTION,
	CONSTRAINT FK_RzR_Rolle FOREIGN KEY (RolleID) REFERENCES [gr1].Rolle(RolleID) ON DELETE CASCADE ON UPDATE NO ACTION
);

/*
** Download History Eintr�ge
*/
CREATE TABLE [gr1].Download_History
(
	DownloadHistoryID INT IDENTITY(1,1) NOT NULL,
	BenutzerID INT NOT NULL,
	BuildID INT NOT NULL,
	DownloadDatum DATE NOT NULL,

	CONSTRAINT PK_DownloadHistoryID PRIMARY KEY (DownloadHistoryID),
	CONSTRAINT FK_Download_Zu_Benutzer FOREIGN KEY (BenutzerID) REFERENCES [gr1].Benutzer(BenutzerID) ON DELETE CASCADE ON UPDATE NO ACTION,
	CONSTRAINT FK_Download_Zu_Build FOREIGN KEY (BuildID) REFERENCES [gr1].Build(ReleaseID) ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE TABLE [gr1].Lizenz
(
	LizenzID INT IDENTITY(1,1) NOT NULL PRIMARY KEY
);

CREATE TABLE [gr1].Lizenz_Zeitlich
(
	LizenzID INT NOT NULL,
	LizensiertProgramm INT NOT NULL,
	StartDatum DATE NOT NULL,
	EndDatum DATE NOT NULL,
	
	CONSTRAINT PK_ZeitlizenzID PRIMARY KEY (LizenzID),
	CONSTRAINT FK_Zeitlizenz_Zu_Lizenz FOREIGN KEY (LizenzID) REFERENCES [gr1].Lizenz(LizenzID) ON DELETE CASCADE ON UPDATE NO ACTION,
	CONSTRAINT FK_Lizensiertes_Programm FOREIGN KEY (LizensiertProgramm) REFERENCES gr1.Programm(ProgrammID) ON DELETE CASCADE ON UPDATE NO ACTION
);


CREATE TABLE [gr1].Lizenz_Versionsorientiert
(
	LizenzID INT NOT NULL,
	Versionserh�hung INT NOT NULL,
	LizensiertRelease INT NOT NULL,

	CONSTRAINT PK_VersionslizenzID PRIMARY KEY (LizenzID),
	CONSTRAINT FK_Versionslizenz_Zu_Lizenz FOREIGN KEY (LizenzID) REFERENCES [gr1].Lizenz(LizenzID) ON DELETE CASCADE ON UPDATE NO ACTION,
	CONSTRAINT FK_Lizensiertes_Release FOREIGN KEY (LizensiertRelease) REFERENCES [gr1].Release(ReleaseID) ON DELETE CASCADE ON UPDATE NO ACTION
);

/*
** Und jetzt auch noch Benutzer <-> Lizenz Matchen
*/
CREATE TABLE [gr1].Benutzer_Zu_Lizenz
(
	BenutzerID INT NOT NULL,
	LizenzID INT NOT NULL,
	/*
	** Hier definiert ein Constraint den zusammengesetzten Prim�rschl�ssel
	*/
	CONSTRAINT PK_Benutzer_Zu_Lizenz PRIMARY KEY (BenutzerID,LizenzID),

	CONSTRAINT FK_BzL_Lizenz FOREIGN KEY (LizenzID) REFERENCES [gr1].Lizenz(LizenzID) ON DELETE CASCADE ON UPDATE NO ACTION,
	CONSTRAINT FK_BzL_Benutzer FOREIGN KEY (BenutzerID) REFERENCES [gr1].Benutzer(BenutzerID) ON DELETE CASCADE ON UPDATE NO ACTION
);
/*
**	2. Schritt des Scripts: Die ersten (offensichtlichen) Indexe anlegen
*/
CREATE UNIQUE NONCLUSTERED INDEX IDX_Programm_Name ON [gr1].Programm (Name ASC);
CREATE UNIQUE NONCLUSTERED INDEX IDX_Benutzer_Name ON [gr1].Benutzer (NutzerNr ASC);

/*
**	3. Schritt des Script: Die weniger offensichtlichen Indexe anlegen (Danke liebes "searchMissingIndexes"-Script)
*/
--Performance f�r Navigation �ber Benutzer_Zu_Lizenz
CREATE NONCLUSTERED INDEX IDX_BzL_BenutzerZuLizenz ON [gr1].Benutzer_Zu_Lizenz (BenutzerID ASC);
CREATE NONCLUSTERED INDEX IDX_BzL_LizenzZuBenutzer ON [gr1].Benutzer_Zu_Lizenz (LizenzID ASC);

--Performance f�r Navigation �ber Download_History
CREATE NONCLUSTERED INDEX IDX_DownloadHistory_Benutzer ON [gr1].Download_History (BenutzerID ASC);
CREATE NONCLUSTERED INDEX IDX_DownloadHistory_Build ON [gr1].Download_History (BuildID ASC);

--Performance f�r Navigation �ber Rolle_Zu_Rechte
CREATE NONCLUSTERED INDEX IDX_RolleZuRechte_Rolle ON [gr1].Rolle_Zu_Rechte (RolleID ASC);
CREATE NONCLUSTERED INDEX IDX_RolleZuRechte_Rechte ON [gr1].Rolle_Zu_Rechte (RechteID ASC);

--Performance f�r Navigation �ber Release
CREATE NONCLUSTERED INDEX IDX_Release_Programm ON [gr1].Release (ReleaseVonProgramm ASC);

--Performance f�r Navigation �ber Subrelease
CREATE NONCLUSTERED INDEX IDX_Subrelease_Release ON [gr1].Subrelease (SubreleaseVonRelease ASC);

--Performance f�r Navigation �ber Build
CREATE NONCLUSTERED INDEX IDX_Build_Subrelease ON [gr1].Build (BuildVonSubrelease ASC); 