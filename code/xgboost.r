library(useful)
library(magrittr)
library(dygraphs)
library(xgboost)

land_train <- readr::read_csv('data/manhattan_Train.csv')
land_val <- readRDS('data/manhattan_Validate.rds')

View(land_train)

table(land_train$HistoricDistrict)

histFormula <- HistoricDistrict ~ FireService + 
    ZoneDist1 + ZoneDist2 + Class + LandUse + 
    OwnerType + LotArea + BldgArea + ComArea + 
    ResArea + OfficeArea + RetailArea + 
    GarageArea + FactryArea + NumBldgs + 
    NumFloors + UnitsRes + UnitsTotal + 
    LotFront + LotDepth + BldgFront + 
    BldgDepth + LotType + Landmark + BuiltFAR +
    Built + TotalValue - 1

landX_train <- build.x(histFormula, data=land_train, 
                       contrasts=FALSE, sparse=TRUE)
landY_train <- build.y(histFormula, data=land_train) %>% 
    as.factor() %>% as.integer() - 1
head(landY_train, n=20)

landX_val <- build.x(histFormula, data=land_val, 
                       contrasts=FALSE, sparse=TRUE)
landY_val <- build.y(histFormula, data=land_val) %>% 
    as.factor() %>% as.integer() - 1

xgTrain <- xgb.DMatrix(data=landX_train, label=landY_train)
xgTrain
xgVal <- xgb.DMatrix(data=landX_val, label=landY_val)

hist1 <- xgb.train(
    data=xgTrain,
    objective='binary:logistic',
    nrounds=1
)
hist1
summary(hist1)

xgb.plot.multi.trees(hist1, feature_names=colnames(landX_train))

hist2 <- xgb.train(
    data=xgTrain,
    objective='binary:logistic',
    nrounds=1,
    eval_metric='logloss',
    watchlist=list(train=xgTrain)
)

hist3 <- xgb.train(
    data=xgTrain,
    objective='binary:logistic',
    nrounds=100,
    eval_metric='logloss',
    watchlist=list(train=xgTrain),
    print_every_n=1
)

xgb.plot.multi.trees(hist3, feature_names=colnames(landX_train))

hist4 <- xgb.train(
    data=xgTrain,
    objective='binary:logistic',
    nrounds=300,
    eval_metric='logloss',
    watchlist=list(train=xgTrain),
    print_every_n=1
)

hist5 <- xgb.train(
    data=xgTrain,
    objective='binary:logistic',
    nrounds=300,
    eval_metric='logloss',
    watchlist=list(train=xgTrain, validate=xgVal),
    print_every_n=1
)

hist5$evaluation_log
dygraph(hist5$evaluation_log)


hist6 <- xgb.train(
    data=xgTrain,
    objective='binary:logistic',
    nrounds=300,
    eval_metric='logloss',
    watchlist=list(train=xgTrain, validate=xgVal),
    print_every_n=1,
    early_stopping_rounds=60
)

dygraph(hist6$evaluation_log)
hist6$best_iteration
hist6$best_score

hist6 %>% 
    xgb.importance(feature_names=colnames(landX_train)) %>% 
    dplyr::slice(1:20) %>% 
    xgb.plot.importance()

hist7 <- xgb.train(
    data=xgTrain,
    objective='binary:logistic',
    nrounds=500,
    eval_metric='logloss',
    watchlist=list(train=xgTrain, validate=xgVal),
    print_every_n=10,
    early_stopping_rounds=60,
    max_depth=9
)

hist8 <- xgb.train(
    data=xgTrain,
    objective='binary:logistic',
    nrounds=1500,
    eval_metric='logloss',
    watchlist=list(train=xgTrain, validate=xgVal),
    print_every_n=20,
    early_stopping_rounds=60,
    max_depth=2
)

hist9 <- xgb.train(
    data=xgTrain,
    objective='binary:logistic',
    nrounds=1500,
    eval_metric='logloss',
    watchlist=list(train=xgTrain, validate=xgVal),
    print_every_n=20,
    early_stopping_rounds=60,
    max_depth=5,
    eta=0.15
)

hist10 <- xgb.train(
    data=xgTrain,
    objective='binary:logistic',
    nrounds=800,
    eval_metric='logloss',
    watchlist=list(train=xgTrain, validate=xgVal),
    print_every_n=1,
    early_stopping_rounds=10,
    max_depth=5,
    eta=0.3,
    subsample=0.5, colsample_bytree=0.5
)

hist11 <- xgb.train(
    data=xgTrain,
    objective='binary:logistic',
    nrounds=1,
    eval_metric='logloss',
    watchlist=list(train=xgTrain, validate=xgVal),
    print_every_n=1,
    early_stopping_rounds=10,
    max_depth=5,
    eta=0.3,
    subsample=0.5, colsample_bytree=0.5,
    num_parallel_tree=100
)

hist12 <- xgb.train(
    data=xgTrain,
    objective='binary:logistic',
    nrounds=100,
    eval_metric='logloss',
    watchlist=list(train=xgTrain, validate=xgVal),
    print_every_n=1,
    early_stopping_rounds=10,
    max_depth=5,
    eta=0.3,
    subsample=0.5, colsample_bytree=0.5,
    num_parallel_tree=20
)
