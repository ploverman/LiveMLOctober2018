library(glmnet)
library(useful)
library(coefplot)

land_train <- readr::read_csv('data/manhattan_Train.csv')

View(land_train)

valueFormula <- TotalValue ~ FireService + 
    ZoneDist1 + ZoneDist2 + Class + LandUse + 
    OwnerType + LotArea + BldgArea + ComArea + 
    ResArea + OfficeArea + RetailArea + 
    GarageArea + FactryArea + NumBldgs + 
    NumFloors + UnitsRes + UnitsTotal + 
    LotFront + LotDepth + BldgFront + 
    BldgDepth + LotType + Landmark + BuiltFAR +
    Built + HistoricDistrict - 1
valueFormula
class(valueFormula)

value1 <- lm(valueFormula, data=land_train)
summary(value1)
coefplot(value1, sort='magnitude')

landX_train <- build.x(valueFormula, data=land_train, 
                       contrasts=FALSE, sparse=TRUE)
landY_train <- build.y(valueFormula, data=land_train)

denseMat <- build.x(valueFormula, data=land_train, 
                       contrasts=FALSE, sparse=FALSE)
pryr::object_size(landX_train)
pryr::object_size(denseMat)

value2 <- glmnet(x=landX_train, y=landY_train, family='gaussian')
head(coef(value2), n=30)
View(as.matrix(coef(value2)))

plot(value2, xvar='lambda')
