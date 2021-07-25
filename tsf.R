library(forecast)
library(tseries)
library(ggplot2)
library(Metrics)
AIStsfData <- read.csv(file.choose(),header = TRUE)
tsfAIS<- ts(AIStsfData[,2], frequency = 7)
tsfAIS
View(tsfAIS)
class(tsfAIS)
ts.plot(tsfAIS,xlab="Week",ylab="No. of ships")
decomptsfAIS <- decompose(tsfAIS)
plot(decomptsfAIS)

TrainData<- window(tsfAIS, start = c(1,1), end=c(24,7), frequency = 7)
TestData<- window(tsfAIS, start = c(25,1), frequency = 7)

TrainData
TestData

### SES Model ###

#Model building
SES_model<-HoltWinters(TrainData,beta = F,gamma = F)

#graphical representation
plot(TrainData)
plot(SES_model,col = "blue", 
     main="SES: Actual(B) vs Forecast(R)")

train_pred=data.frame(SES_model$fitted)
head(train_pred)

#train data metric
mae(TrainData,train_pred$xhat)
rmse(TrainData,train_pred$xhat)
mape(TrainData,train_pred$xhat)

#test data metric
sesforecast<- forecast(SES_model,14)
ts.plot(TestData, sesforecast$mean,col = c("blue", "red"), 
        main="SES: Actual(B) vs Forecast(R)")

mae(TestData,sesforecast$mean)
rmse(TestData,sesforecast$mean)
mape(TestData,sesforecast$mean)

plot(sesforecast,main = "SES Model with Forecasting")

#model stability
Box.test( sesforecast$residuals,type = "Ljung-Box")
hist(hmadforecast$residuals)




### Holts winter additive ###

hmmodelAdd<-HoltWinters(TrainData, seasonal = "additive")

#graphical representation
plot(TrainData)
plot(hmmodelAdd)

train_pred=data.frame(hmmodelAdd$fitted)
head(train_pred)

#train data
mae(TrainData,train_pred$xhat)
rmse(TrainData,train_pred$xhat)
mape(TrainData,train_pred$xhat)

hmadforecast<- forecast(hmmodelAdd,14)
mae(TestData,hmadforecast$mean)
rmse(TestData,hmadforecast$mean)
mape(TestData,hmadforecast$mean)
ts.plot(TestData, hmadforecast$mean,col = c("red", "blue"), 
        main="HWM - Add: Actual(R) vs Forecast(B)")
Box.test( hmadforecast$residuals,type = "Ljung-Box")
hist(hmadforecast$residuals)

plot(hmadforecast,main = "Holts Winter Model (Additive) with Forecasting")

### Holts Multiplicative ###
hmmodelMul<- HoltWinters(TrainData, seasonal = "multiplicative")

train_pred=data.frame(hmmodelMul$fitted)
head(train_pred)

#train data
mae(TrainData,train_pred$xhat)
rmse(TrainData,train_pred$xhat)
mape(TrainData,train_pred$xhat)

hmmulforecast <- forecast(hmmodelMul, 14)
mae(TestData,hmmulforecast$mean)
rmse(TestData,hmmulforecast$mean)
mape(TestData,hmmulforecast$mean)
ts.plot(TestData,hmmulforecast$mean,col=c("blue", "red"), main="HWM - Mul: Actual(B) vs Forecast(R)")

plot(hmmulforecast,main = "Holts Winter Model (Multiplicative) with Forecasting")

Box.test( hmmulforecast$residuals,type = "Ljung-Box")
hist(hmmulforecast$residuals)

### arima additive ###
kpss.test(TrainData)
kpss.test(diff(TrainData))
plot(diff(TrainData))
acf(diff(TrainData)) #q=1
pacf(diff(TrainData)) #p=3
armodadd<- arima(TrainData,c(3,1,1), seasonal = list(order = c(3,1,1), period = 7)) #p,d,q

#metric values for train
mean(abs(armodadd$residuals)) #mae
sqrt(mean((armodadd$residuals)^2)) #rmse
mean(abs(armodadd$residuals/TrainData)) #mape

#metric values for test
armaddfor<-forecast(armodadd,14)
mae(TestData,armaddfor$mean)
rmse(TestData,armaddfor$mean)
mape(TestData,armaddfor$mean)

Box.test( armodadd$residuals,type = "Ljung-Box")
hist(armodadd$residuals)
ts.plot(TestData,armaddfor$mean,col=c("blue", "red"), main="HWM - Mul: Actual(B) vs Forecast(R)")

plot(armaddfor,main = "ARIMA Model (Additive) with Forecasting")

### arima multiplicative ###
kpss.test(diff(log(TrainData)))
plot(diff(log(TrainData)))
acf(diff(log(TrainData))) #q=1
pacf(diff(log(TrainData))) #p=3
armodmul<- arima(log(TrainData), c(3,1,1), seasonal = list(order=c(3,1,1), period=7)
                 ,optim.control = list(maxit = 1000))

armodmul$residuals

#metric data for train
armmulfor<-forecast(armodmul,168)
mean(abs(armmulfor$fitted)) #mae
sqrt(mean((armmulfor$fitted)^2)) #rmse
mean(abs(armmulfor$fitted/TrainData)) #mape

#metric data for test
armmulfor<-forecast(armodmul,14)
mae(TestData,2.71828^armmulfor$mean)
rmse(TestData,2.71828^armmulfor$mean)
mape(TestData,2.71828^armmulfor$mean)
Box.test( armmulfor$residuals,type = "Ljung-Box")
hist(armmulfor$residuals)
ts.plot(TestData,2.71828^armmulfor$mean,col=c("blue", "red"), main="HWM - Mul: Actual(B) vs Forecast(R)")

plot(armmulfor,main = "ARIMA Model (Multiplicative) with Forecasting")

### auto.arima ###
#autoarm<-auto.arima(TrainData,trace = T,test = 'kpss',ic="bic")
autoarm<-auto.arima(TrainData, d=1,trace = T, stationary = T, seasonal = T)

#metric values for train
mean(abs(autoarm$residuals)) #mae
sqrt(mean((autoarm$residuals)^2)) #rmse
mean(abs(autoarm$residuals/TrainData)) #mape

#metric values for test
autoarmfor<-forecast(autoarm,14)
mae(TestData,autoarmfor$mean)
rmse(TestData,autoarmfor$mean)
mape(TestData,autoarmfor$mean)

Box.test( autoarmfor$residuals,type = "Ljung-Box")
hist(autoarmfor$residuals)
ts.plot(TestData,autoarmfor$mean,col=c("blue", "red"), main="Auto-Arima: Actual(B) vs Forecast(R)")

plot(autoarmfor,main = "Auto ARIMA Model with Forecasting")

