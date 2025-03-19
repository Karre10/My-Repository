USE BOWOOD_Rodco_2023_EDM_gKKd

SELECT * FROm PortInfo

DECLARE @PortfolioId INT = 7
DECLARE @Peril INT = 2


DECLARE @OccLookup AS TABLE ( Scheme VARCHAR(50), CODE VARCHAR(50), NAME VARCHAR(MAX) )
DECLARE @ConstLookup AS TABLE ( Scheme VARCHAR(50), CODE VARCHAR(50), NAME VARCHAR(MAX) )

INSERT INTO @OccLookup
SELECT Scheme, Code, Name FROM Lookup.dbo.vulnnames WHERE Country = 'us' AND AttribId = 521

INSERT INTO @ConstLookup
SELECT Scheme, Code, Name FROM Lookup.dbo.vulnnames WHERE Country = 'us' AND AttribId = 501



---- Policy Details
DECLARE @PolicyDeets TABLE ( AccGrpNum VARCHAR(30), PartOf FLOAT, Share FLOAT )

INSERT INTO @PolicyDeets
SELECT DISTINCT
	ACCGRPNUM,
	PARTOF,
	CASE	WHEN BLANLIMAMT = 0 THEN 1 
			WHEN BLANLIMAMT > 1 THEN 1 
			ELSE BLANLIMAMT END
FROM Policy PO
JOIN portacct PA ON PA.ACCGRPID = PO.ACCGRPID
JOIN accgrp AC On AC.AccGrpId = PA.AccGRpId
JOIN Property PR ON PR.AccGRpId = AC.AccGRPId
JOIN LocCvg LC On LC.LocId = PR.LocId
	AND LC.Peril = PO.Policytype            
WHERE PORTINFOID = @PortfolioId
	AND Peril = @Peril


IF OBJECT_ID('tempdb..#LocationDeets') IS NOT NULL DROP TABLE #LocationDeets
	CREATE TABLE #LocationDeets 
(	LocId INT, LocNum VARCHAR(30), AccntNum VARCHAR(MAX), PolNum VARCHAR(MAX), AccntName VARCHAR(MAX), ContractName VARCHAR(30), StreetAddress VARCHAR(MAX), Postcode VARCHAR(10), City VARCHAR(MAX), 
	County VARCHAR(MAX), State VARCHAR(MAX), Country VARCHAR(2), Latitude FLOAT, Longitude FLOAT, Inception DATE, Expiry DATE, AddressMatch VARCHAR(40), Occupancy VARCHAR(MAX), Construction VARCHAR(MAX),
	YearBuilt VARCHAR(4), YearUpgrade varchar(4), DistanceToCoast FLOAT, DistanceBanding VARCHAR(40), Elevation FLOAT, SoilType VARCHAR(30), Liquefaction VARCHAR(30), ShareTIV FLOAT, SharePremium FLOAT, 
	USERTXT2 varchar(50), FLoorARea FLOAT,
	--BuildingHeight FLOAT, 
	NumStoreys FLOAT, RoofGeom FLOAT, RoofSys FLOAT, RoofAge FLOAT, CladSys FLOAT, RoofAnch FLOAT, Basement FLOAT, 
	Eqslins FLOAT, SprType FLOAT, StoryProf FLOAT, Cladding FLOAT, ShapeConf FLOAT, OverProf FLOAT, DistCoast FLOAT, WindDeductible FLOAT )


INSERT INTO #LocationDeets 	
SELECT DISTINCT
	PR.LocId,
	PR.LocNum,
	AC.ACCGRPNUM,
	PO.PolicyNum,
	AC.AccGRpname,
	AC.USERTXT1,
	LEFT([CAT_Modelling_SQL_yVe].[hxa].[fn_titlecase](AD.StreetAddress),50) StreetAddress,
	AD.PostalCode,
	[CAT_Modelling_SQL_yVe].[hxa].[fn_titlecase](AD.CityName) City,
	[CAT_Modelling_SQL_yVe].[hxa].[fn_titlecase](AD.Admin2Name) County,
	[CAT_Modelling_SQL_yVe].[hxa].[fn_titlecase](AD.Admin1Name) State,
	AD.CountryCode,
	AD.Latitude,
	AD.Longitude,
	PO.InceptDate,
	PO.ExpireDate,
	CASE 
		WHEN GeoResolutionCode = 1 THEN 'Coordinate'
		WHEN GeoResolutionCode = 2 THEN 'High Res Street'
		WHEN GeoResolutionCode = 3 THEN 'High Res Post Code'
		WHEN GeoResolutionCode = 4 THEN 'Street Name'
		WHEN GeoResolutionCode = 5 THEN 'Postal Code'
		WHEN GeoResolutionCode = 7 THEN 'City'
		ELSE 'Worse Than City'
	END AS AddressMatch,
	[CAT_Modelling_SQL_yVe].[hxa].[fn_titlecase](om.Name) Occupancy,
	[CAT_Modelling_SQL_yVe].[hxa].[fn_titlecase](cm.Name) Construction,
	CASE WHEN pr.yearbuilt > GETDATE() THEN '' ELSE year(pr.yearbuilt) END YearBuilt,
	CASE WHEN LEFT(CAST(hu.yearupgrad AS DATE),4)  > YEAR(GETDATE()) THEN '' ELSE LEFT(CAST(hu.yearupgrad AS DATE),4) END AS YearUpgrade,
	DistCoast  DistanceToCoast,
	CASE WHEN DistCoast > 0.00001 AND DistCoast < 0.5 THEN 'Under 0.5 mile'
		WHEN DistCoast >= 0.5 AND DistCoast < 1 THEN '0.5 - 1 miles'
		WHEN DistCoast >= 1 AND DistCoast < 2 THEN '1 - 2 miles'
		WHEN DistCoast >= 2 AND DistCoast < 5 THEN '2 - 5 miles'
		WHEN DistCoast >= 5 AND DistCoast < 10 THEN '5 - 10 miles'
		WHEN DistCoast >= 10 AND DistCoast < 25 THEN '10 - 25 miles'
		WHEN DistCoast >= 25 AND DistCoast < 50 THEN '25 - 50 miles'
		WHEN DistCoast >= 50 AND DistCoast < 900 THEN 'Over 50 miles'
	ELSE 'Unknown' END DistanceBanding,
	ROUND(HU.Elevation,2) Elevation,
		CASE 
			WHEN SOILTYPE BETWEEN 0.01 AND 0.75 THEN 'Very Hard Rock'
			WHEN SOILTYPE BETWEEN 0.76 AND 1.25 THEN 'Rock'
			WHEN SOILTYPE BETWEEN 1.26 AND 1.75 THEN 'Rock & Soft Rock'
			WHEN SOILTYPE BETWEEN 1.76 AND 2.25 THEN 'Soft Rock'
			WHEN SOILTYPE BETWEEN 2.26 AND 2.75 THEN 'Soft Rock & Stiff Soil'
			WHEN SOILTYPE BETWEEN 2.76 AND 3.25 THEN 'Stiff Soil'	
			WHEN SOILTYPE BETWEEN 3.26 AND 3.75 THEN 'Stiff & Soft Soil'
			WHEN SOILTYPE BETWEEN 3.76 AND 4.25 THEN 'Soft Soil'
			WHEN SOILTYPE BETWEEN 4.26 AND 4.50 THEN 'Very Soft Soil'		
		ELSE 'Unknown' END AS SoilType,
		CASE 
			WHEN LIQUEFACT BETWEEN 1.00 AND 1.25 THEN 'Very Low'
			WHEN LIQUEFACT BETWEEN 1.26 AND 1.75 THEN 'Very Low to Low'
			WHEN LIQUEFACT BETWEEN 1.76 AND 2.25 THEN 'Low'
			WHEN LIQUEFACT BETWEEN 2.26 AND 2.75 THEN 'Low to Moderate'
			WHEN LIQUEFACT BETWEEN 2.76 AND 3.25 THEN 'Moderate'	
			WHEN LIQUEFACT BETWEEN 3.26 AND 3.75 THEN 'Moderate to High'
			WHEN LIQUEFACT BETWEEN 3.76 AND 4.25 THEN 'High'
			WHEN LIQUEFACT BETWEEN 4.26 AND 4.75 THEN 'High to Very High'		
			WHEN LIQUEFACT BETWEEN 4.76 AND 5 THEN 'Very High'		
		ELSE 'Unknown' END AS Liquefaction,
	SUM(ISNULL(LC.ValueAmt,0))*ISNULL(PD.Share,0) AS ShareTIV,
	CASE WHEN PR.USERTXT1 = '' THEN '0' WHEN PR.USERTXT1 IS NULL THEN 0 ELSE CAST(PR.USERTXT1 AS FLOAT) * ISNULL(PD.Share,0) END AS SharePremium,	
	PR.USERTXT2,
	FLOORAREA,
	--BLDGHEIGHT,
	NumStories,
	ISNULL(ROOFGEOM, 0),
	ISNULL(ROOFSYS, 0),
	ISNULL(ROOFAGE, 0),
	ISNULL(CLADSYS, 0),
	ISNULL(ROOFANCH, 0),
	ISNULL(BASEMENT, 0),
	ISNULL(EQSLINS, 0),
	ISNULL(SPNKLRTYPE, 0),
	ISNULL(STORYPROF, 0),
	ISNULL(CLADDING, 0),
	ISNULL(SHAPECONF, 0),
	ISNULL(OVERPROF, 0),
	DistCoast,
	hu.SITEDEDAMT
FROM portacct PA 
JOIN accgrp AC On AC.AccGrpId = PA.AccGRpId
JOIN Property PR ON PR.AccGRpId = AC.AccGRPId
JOIN Address AD ON AD.AddressId = Pr.AddressId
JOIN LocCvg LC On LC.LocId = PR.LocId
LEFT JOIN Policy PO ON PO.ACCGRPID = AC.ACCGRPID AND PO.POLICYTYPE = LC.PERIL
LEFT JOIN eqdet EQ ON EQ.LocId = LC.LocId
LEFT JOIN hudet HU ON HU.LocId = LC.LocId 
LEFT JOIN @OccLookup om ON om.Scheme = pr.OCCSCHEME AND om.code = CAST(pr.OCCTYPE AS VARCHAR(50))
LEFT JOIN @ConstLookup cm ON cm.Scheme = pr.BLDGSCHEME AND cm.CODE = pr.BLDGCLASS
LEFT JOIN @PolicyDeets PD ON PD.AccGrpNum = AC.ACCGRPNUM
WHERE Peril = @Peril
	AND	PortInfoId = @PortfolioId
GROUP BY
	PR.LocId,
	PR.LocNum,
	AC.ACCGRPNUM,
	PO.PolicyNum,
	AC.AccGRpname,
	AD.StreetAddress,
	AD.PostalCode,
	AD.CityName,
	AD.Admin2Name,
	AD.Admin1Name,
	AD.CountryCode,
	OM.NAME,
	CM.NAME,
	AD.Admin1GeoID,
	AD.Admin2Code,
	PO.InceptDate,
	PO.ExpireDate,
	AC.USERTXT2,
	CASE 
		WHEN GeoResolutionCode = 1 THEN 'Coordinate'
		WHEN GeoResolutionCode = 2 THEN 'High Res Street'
		WHEN GeoResolutionCode = 3 THEN 'High Res Post Code'
		WHEN GeoResolutionCode = 4 THEN 'Street Name'
		WHEN GeoResolutionCode = 5 THEN 'Postal Code'
		WHEN GeoResolutionCode = 7 THEN 'City'
		ELSE 'Worse Than City'
	END,
	CASE 
		WHEN SOILTYPE BETWEEN 0.01 AND 0.75 THEN 'Very Hard Rock'
		WHEN SOILTYPE BETWEEN 0.76 AND 1.25 THEN 'Rock'
		WHEN SOILTYPE BETWEEN 1.26 AND 1.75 THEN 'Rock & Soft Rock'
		WHEN SOILTYPE BETWEEN 1.76 AND 2.25 THEN 'Soft Rock'
		WHEN SOILTYPE BETWEEN 2.26 AND 2.75 THEN 'Soft Rock & Stiff Soil'
		WHEN SOILTYPE BETWEEN 2.76 AND 3.25 THEN 'Stiff Soil'	
		WHEN SOILTYPE BETWEEN 3.26 AND 3.75 THEN 'Stiff & Soft Soil'
		WHEN SOILTYPE BETWEEN 3.76 AND 4.25 THEN 'Soft Soil'
		WHEN SOILTYPE BETWEEN 4.26 AND 4.50 THEN 'Very Soft Soil'		
	ELSE 'Unknown' END,
	CASE 
		WHEN LIQUEFACT BETWEEN 1.00 AND 1.25 THEN 'Very Low'
		WHEN LIQUEFACT BETWEEN 1.26 AND 1.75 THEN 'Very Low to Low'
		WHEN LIQUEFACT BETWEEN 1.76 AND 2.25 THEN 'Low'
		WHEN LIQUEFACT BETWEEN 2.26 AND 2.75 THEN 'Low to Moderate'
		WHEN LIQUEFACT BETWEEN 2.76 AND 3.25 THEN 'Moderate'	
		WHEN LIQUEFACT BETWEEN 3.26 AND 3.75 THEN 'Moderate to High'
		WHEN LIQUEFACT BETWEEN 3.76 AND 4.25 THEN 'High'
		WHEN LIQUEFACT BETWEEN 4.26 AND 4.75 THEN 'High to Very High'		
		WHEN LIQUEFACT BETWEEN 4.76 AND 5 THEN 'Very High'		
	ELSE 'Unknown' END,
	[CAT_Modelling_SQL_yVe].[hxa].[fn_titlecase](om.Name),
	[CAT_Modelling_SQL_yVe].[hxa].[fn_titlecase](cm.NAme),
	pr.yearbuilt,
	hu.YEARUPGRAD,
	AD.Latitude,
	AD.Longitude,
	HU.Elevation,
	CASE WHEN DistCoast > 0.00001 AND DistCoast < 0.5 THEN 'Under 0.5 mile'
		WHEN DistCoast >= 0.5 AND DistCoast < 1 THEN '0.5 - 1 miles'
		WHEN DistCoast >= 1 AND DistCoast < 2 THEN '1 - 2 miles'
		WHEN DistCoast >= 2 AND DistCoast < 5 THEN '2 - 5 miles'
		WHEN DistCoast >= 5 AND DistCoast < 10 THEN '5 - 10 miles'
		WHEN DistCoast >= 10 AND DistCoast < 25 THEN '10 - 25 miles'
		WHEN DistCoast >= 25 AND DistCoast < 50 THEN '25 - 50 miles'
		WHEN DistCoast >= 50 AND DistCoast < 900 THEN 'Over 50 miles'
	ELSE 'Unknown' END,
	DISTCOAST,
	PR.USERTXT1,
	PR.USERTXT2,
	bldgclass,
	bldgscheme,
	PD.Share,
	PD.PartOf,
	FLOORAREA,
	--BLDGHEIGHT,
	NUMSTORIES,
	ROOFGEOM,
	ROOFSYS,
	ROOFAGE,
	CLADSYS,
	ROOFANCH,
	BASEMENT,
	EQSLINS,
	SPNKLRTYPE,
	STORYPROF,
	CLADDING,
	SHAPECONF,
	OVERPROF,
	DistCoast,
	hu.SITEDEDAMT,
	AC.USERTXT1


-- Location Lv.
SELECT DISTINCT
	LocId,
	AccntNum,
	AccntName,
	StreetAddress,
	Postcode,
	County,
	State,
	Country,
	CONCAT(State,County) AS UniqueID,
	Latitude,
	Longitude,
	AddressMatch,
	Occupancy,
	Construction,
	Inception,
	Expiry,
	CASE WHEN YearBuilt = 0 THEN '' ELSE YearBuilt END AS YearBuilt,
	CASE WHEN YearUpgrade = 0 THEN '' ELSE YearUpgrade END AS YearUpgrade,
	FloorArea,
	DistanceBanding AS [Distance Banding],
	DistanceToCoast AS [Distance To Coast],
	Elevation,
	SoilType,
	Liquefaction,
	WindDeductible AS Deductible,
	CAST(ShareTIV AS FLOAT) [Share TIV],
	CAST(SharePremium AS FLOAT) [Share Premium],
	ROUND((SharePremium/ShareTIV)*100,2) AS Rate
FROM #LocationDeets
ORDER BY LocId



-- Account Lv
SELECT 
	AccntNum,
	AccntName,
	Count(LocId) Locations,
	SUM(ShareTIV) InsuredValues,
	SUM(SharePremium) Premium 
FROM #LocationDeets
GROUP BY
	AccntNum,
	AccntName



-- Hazard 
DECLARE @HazDeets TABLE ( HazOrder INT, DistanceBanding VARCHAR(20) )
INSERT INTO @HazDeets VALUES (1,'Under 0.5 mile')
INSERT INTO @HazDeets VALUES (2,'0.5 - 1 miles')
INSERT INTO @HazDeets VALUES (3,'1 - 2 miles')
INSERT INTO @HazDeets VALUES (4,'2 - 5 miles')
INSERT INTO @HazDeets VALUES (5,'5 - 10 miles')
INSERT INTO @HazDeets VALUES (6,'10 - 25 miles')
INSERT INTO @HazDeets VALUES (7,'25 - 50 miles')
INSERT INTO @HazDeets VALUES (8,'Over 50 miles')
INSERT INTO @HazDeets VALUES (9,'Unknown')

SELECT 
	HD.DistanceBanding AS [Distance to Coast],
	Count(LocId) Locations,
	ISNULL(SUM(ShareTIV),0) InsuredValues,
	ISNULL(SUM(SharePremium),0) Premium 
FROM @HazDeets HD
LEFT JOIN #LocationDeets LD ON LD.DistanceBanding = HD.DistanceBanding
GROUP BY
	HD.DistanceBanding,
	HD.HazOrder
ORDER BY HazOrder


DECLARE @EQDeets TABLE ( HazOrder INT, Liquefaction VARCHAR(30) )
INSERT INTO @EQDeets VALUES (1,'Very Low')
INSERT INTO @EQDeets VALUES (2,'Very Low to Low')
INSERT INTO @EQDeets VALUES (3,'Low')
INSERT INTO @EQDeets VALUES (4,'Low to Moderate')
INSERT INTO @EQDeets VALUES (5,'Moderate')
INSERT INTO @EQDeets VALUES (6,'Moderate to High')
INSERT INTO @EQDeets VALUES (7,'High')
INSERT INTO @EQDeets VALUES (8,'High to Very High')
INSERT INTO @EQDeets VALUES (9,'Very High')
INSERT INTO @EQDeets VALUES (10,'Unknown')


-- Geocoding
SELECT 
	AddressMatch,
	Count(LocId) Locations,
	SUM(ShareTIV) InsuredValues,
	SUM(SharePremium) Premium 
FROM #LocationDeets
GROUP BY
	AddressMatch
ORDER BY SUM(ShareTIV) DESC

-- Occupancy
SELECT 
	Occupancy,
	Count(LocId) Locations,
	SUM(ShareTIV) InsuredValues,
	SUM(SharePremium) Premium 
FROM #LocationDeets
GROUP BY
	Occupancy
ORDER BY SUM(ShareTIV) DESC

-- Construction
SELECT 
	Construction,
	Count(LocId) Locations,
	SUM(ShareTIV) InsuredValues,
	SUM(SharePremium) Premium 
FROM #LocationDeets
GROUP BY
	Construction
ORDER BY SUM(ShareTIV) DESC


-- DataQuality Summary

SELECT
	CASE WHEN KnownOccupancy = 0 THEN 0 ELSE CAST(KnownOccupancy AS FLOAT)/ CAST(Total AS FLOAT) END KnownOccupancy,
	CASE WHEN KnownConstruction = 0 THEN 0 ELSE CAST(KnownConstruction AS FLOAT)/ CAST(Total AS FLOAT) END KnownConstruction,
	CASE WHEN KnownYearBuilt = 0 THEN 0 ELSE CAST(KnownYearBuilt AS FLOAT)/ CAST(Total AS FLOAT) END KnownYearBuilt,
	CASE WHEN KnownYearUpgrade = 0 THEN 0 ELSE CAST(KnownYearUpgrade AS FLOAT)/ CAST(Total AS FLOAT) END KnownYearUpgrade,
	--CASE WHEN KnownBuildingHeight = 0 THEN 0 ELSE CAST(KnownBuildingHeight AS FLOAT)/ CAST(Total AS FLOAT) END KnownBuildingHeight,
	CASE WHEN KnownFloorArea = 0 THEN 0 ELSE CAST(KnownFloorArea AS FLOAT)/ CAST(Total AS FLOAT) END KnownFloorArea,
	CASE WHEN KnownNumStoreys = 0 THEN 0 ELSE CAST(KnownNumStoreys AS FLOAT)/ CAST(Total AS FLOAT) END KnownNumStoreys,
	CASE WHEN Coordinate = 0 THEN 0 ELSE CAST(Coordinate AS FLOAT)/ CAST(Total AS FLOAT) END Coordinate,
	CASE WHEN HighResStreet = 0 THEN 0 ELSE CAST(HighResStreet AS FLOAT)/ CAST(Total AS FLOAT) END HighResStreet,
	CASE WHEN HighResPostcode = 0 THEN 0 ELSE CAST(HighResPostcode AS FLOAT)/ CAST(Total AS FLOAT) END HighResPostcode,
	CASE WHEN Street = 0 THEN 0 ELSE CAST(Street AS FLOAT)/ CAST(Total AS FLOAT) END Street,
	CASE WHEN Postcode = 0 THEN 0 ELSE CAST(Postcode AS FLOAT)/ CAST(Total AS FLOAT) END Postcode,
	CASE WHEN City = 0 THEN 0 ELSE CAST(City AS FLOAT)/ CAST(Total AS FLOAT) END City,
	CASE WHEN WorseThanCity = 0 THEN 0 ELSE CAST(WorseThanCity AS FLOAT)/ CAST(Total AS FLOAT) END WorseThanCity,
	CASE WHEN ROOFGEOM = 0 THEN 0 ELSE CAST(ROOFGEOM AS FLOAT)/ CAST(Total AS FLOAT) END ROOFGEOM,
	CASE WHEN ROOFSYS = 0 THEN 0 ELSE CAST(ROOFSYS AS FLOAT)/ CAST(Total AS FLOAT) END ROOFSYS,
	CASE WHEN ROOFAGE = 0 THEN 0 ELSE CAST(ROOFAGE AS FLOAT)/ CAST(Total AS FLOAT) END ROOFAGE,
	CASE WHEN CLADSYS = 0 THEN 0 ELSE CAST(CLADSYS AS FLOAT)/ CAST(Total AS FLOAT) END CLADSYS,
	CASE WHEN ROOFANCH = 0 THEN 0 ELSE CAST(ROOFANCH AS FLOAT)/ CAST(Total AS FLOAT) END ROOFANCH,
	CASE WHEN BASEMENT = 0 THEN 0 ELSE CAST(BASEMENT AS FLOAT)/ CAST(Total AS FLOAT) END BASEMENT
FROM (
	SELECT
		SUM(Total) Total,
		SUM(KnownOccupancy) KnownOccupancy,
		SUM(KnownConstruction) KnownConstruction,
		SUM(KnownYearBuilt) KnownYearBuilt,
		SUM(KnownYearUpgrade) KnownYearUpgrade,
		--SUM(KnownBuildingHeight) KnownBuildingHeight,
		SUM(KnownFloorArea) KnownFloorArea,
		SUM(KnownNumStoreys) KnownNumStoreys,
		SUM(Coordinate) Coordinate,
		SUM(HighResStreet) HighResStreet,
		SUM(HighResPostcode) HighResPostcode,
		SUM(Street) Street,
		SUM(Postcode) Postcode,
		SUM(City) City,
		SUM(WorseThanCity) WorseThanCity,
		SUM(ROOFGEOM) ROOFGEOM,
		SUM(ROOFSYS) ROOFSYS,
		SUM(ROOFAGE) ROOFAGE,
		SUM(CLADSYS) CLADSYS,
		SUM(ROOFANCH) ROOFANCH,
		SUM(BASEMENT) BASEMENT,
		SUM(EQSLINS) EQSLINS,
		SUM(SprType) SprType,
		SUM(STORYPROF) STORYPROF,
		SUM(CLADDING) CLADDING,
		SUM(SHAPECONF) SHAPECONF,
		SUM(OVERPROF) OVERPROF
	FROM (
		SELECT
			LocId,
			1 AS Total,
			CASE WHEN Occupancy <> 'Unknown' THEN 1 ELSE 0 END AS KnownOccupancy,
			CASE WHEN Construction <> 'Unknown' THEN 1 ELSE 0 END AS KnownConstruction,
			CASE WHEN YearBuilt <> '0' THEN 1 ELSE 0 END AS KnownYearBuilt,
			CASE WHEN YearUpgrade <> '' THEN 1 ELSE 0 END AS KnownYearUpgrade,
			--CASE WHEN BuildingHeight <> 0 THEN 1 ELSE 0 END AS KnownBuildingHeight,
			CASE WHEN FloorArea <> 0 THEN 1 ELSE 0 END AS KnownFloorArea,
			CASE WHEN NumStoreys <> 0 THEN 1 ELSE 0 END AS KnownNumStoreys,
			CASE WHEN AddressMatch = 'Coordinate' THEN 1 ELSE 0 END AS Coordinate,
			CASE WHEN AddressMatch = 'High Res Street' THEN 1 ELSE 0 END AS HighResStreet,
			CASE WHEN AddressMatch = 'High Res Postcode' THEN 1 ELSE 0 END AS HighResPostcode,
			CASE WHEN AddressMatch = 'Street Name' THEN 1 ELSE 0 END AS Street,
			CASE WHEN AddressMatch = 'Postal code' THEN 1 ELSE 0 END AS Postcode,
			CASE WHEN AddressMatch = 'City' THEN 1 ELSE 0 END AS City,
			CASE WHEN AddressMatch = 'Worse Than City' THEN 1 ELSE 0 END AS WorseThanCity,
			CASE WHEN ROOFGEOM = 0 THEN 0 ELSE 1 END AS ROOFGEOM,
			CASE WHEN ROOFSYS = 0 THEN 0 ELSE 1 END AS ROOFSYS,
			CASE WHEN ROOFAGE = 0 THEN 0 ELSE 1 END AS ROOFAGE,
			CASE WHEN CLADSYS = 0 THEN 0 ELSE 1 END AS CLADSYS,
			CASE WHEN ROOFANCH = 0 THEN 0 ELSE 1 END AS ROOFANCH,
			CASE WHEN BASEMENT = 0 THEN 0 ELSE 1 END AS BASEMENT,
			CASE WHEN EQSLINS = 0 THEN 0 ELSE 1 END AS EQSLINS,
			CASE WHEN SprType = 0 THEN 0 ELSE 1 END AS SprType,
			CASE WHEN STORYPROF = 0 THEN 0 ELSE 1 END AS STORYPROF,
			CASE WHEN CLADDING = 0 THEN 0 ELSE 1 END AS CLADDING,
			CASE WHEN SHAPECONF = 0 THEN 0 ELSE 1 END AS SHAPECONF,
			CASE WHEN OVERPROF = 0 THEN 0 ELSE 1 END AS OVERPROF
		FROM #LocationDeets
		) t
	)t2

