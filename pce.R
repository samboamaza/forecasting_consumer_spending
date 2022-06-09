#Importing the relevant librarieslibrary(forecast)
library(tseries)
library(vars)
library(forecast)
library(quantmod)
library(fGarch)
library(ggplot2)

# Set my working directory
setwd("") #insert file path to where pce data is saved 

#importing real consumer spending expendotures data
pce <- read.csv("PCE.csv", header = TRUE)
pce <- pce[-c(1:372),]
pce <- pce[,2]
#converting consumer expenditure data to time series 
pce.ts <- ts(pce, start = 1990, frequency = 12)
plot(pce.ts, main = "Real Consumer Spending Expenditures" , type = "l", col = "blue", ylab = "Billions of 2012 dollars", xlab = "Year")

#testing for staionarity 
# rejecting the null at 10% significance level
pp.test(pce.ts)
adf.test(pce.ts)

#Correlogram for the pce data 
acf(coredata(pce.ts), main = "ACF plot of Real Consumer Expenditures", col = "red")
pacf(coredata(pce.ts), main = "PACF plot of Real Consumer Expenditures", col = "green")

#take the difference of the log of pce in order to make it stationary
pce_df <- diff(log(pce.ts))

plot(pce_df, main = "Real Consumer Spending Expenditures" , type = "l", col = "blue", ylab = "Billions of 2012 dollars", xlab = "Year")


pp.test(pce_df)
adf.test(pce_df)

acf(coredata(pce_df), main = "ACF plot of Real Consumer Expenditures", col = "red")
pacf(coredata(pce_df), main = "PACF plot of Real Consumer Expenditures", col = "green")
#Correlogram incdicates that the difference of the log of pce is white noise model. Thus, we make estimate
#the white noise model and make comparisons with other models

#Estimating the model using ARMA(1,0,0)
model.wn <- arima(pce_df, order = c(0,0,0), method = "ML")
summary(model.wn)

#VAR estimates
emp <- read.csv("emp.csv", header = TRUE) #importing employment data
emp <- emp[-c(1:120),] #eliinating rows before january 1990
emp <- emp[,2]

pp.test(emp)
adf.test(emp)

acf(coredata(emp))
pacf(coredata(emp))

#converting employment ratio data to employment growth rate
emp_df <- diff(log(emp))

pp.test(emp_df)
adf.test(emp_df)

acf(coredata(emp_df)) # employment data is also a white noise
pacf(coredata(emp_df))

#Including S&P stock prices data 
sp500 = read.csv("s&p500.csv", header = TRUE)
sp500 <- sp500[-c(1:120),] #eliinating rows before january 1990
sp500 = sp500[,6]

sp500_rtn <- diff(log(sp500))
adf.test(sp500_rtn) #ADF UNIT ROOT TEST
pp.test(sp500_rtn) #pp unit root test

#Includign consumer sentiment index data
csent = read.csv("UMCSENT.csv", header = TRUE)
csent = csent[-c(1:120),]
csent = csent[,2]

csent_df <- diff(log(csent))
adf.test(csent_df) #ADF UNIT ROOT TEST
pp.test(csent_df) #pp unit root test


#VAR EStimates
#VAR1- bivariate VAR with growth in consumer spending and employt ratio
var_21 <- ts(cbind(pce_df,emp_df),start = 1990,frequency = 12) 
#VAR2- bivariate VAR with growth in consumer spending and sp500
var_22 <- ts(cbind(pce_df,sp500_rtn),start = 1990,frequency = 12) 
#VAR3- bivariate VAR with growth in consumer spending and consumer sentiment index
var_23 <- ts(cbind(pce_df,csent_df),start = 1990,frequency = 12) 

#VAR3- bivariate VAR with growth in consumer spending, employment and s&p 500 stock returns
var_31 <- ts(cbind(pce_df,emp_df,sp500_rtn),start = 1990,frequency = 12) 
#VAR3- bivariate VAR with growth in consumer spending,employment and consumer sentiment index
var_32 <- ts(cbind(pce_df,emp_df,csent_df),start = 1990,frequency = 12) 
#VAR3- bivariate VAR with growth in consumer spending, s&p 500 sttock returns and consumer sentiment index
var_33 <- ts(cbind(pce_df, sp500_rtn, csent_df),start = 1990,frequency = 12) 

#VAR3- bivariate VAR with growth in consumer spending, employment, stock returns and consumer sentiment index
var_41 <- ts(cbind(pce_df,emp_df,sp500_rtn, csent_df),start = 1990,frequency = 12) 

#selecting the optimal of lags for the  VAR system
Info.crit1 = VARselect(var_21,lag.max = 8,type = "const") 
Info.crit2 = VARselect(var_22,lag.max = 8,type = "const") 
Info.crit3 = VARselect(var_23,lag.max = 8,type = "const") 
Info.crit4 = VARselect(var_31,lag.max = 8,type = "const") 
Info.crit5 = VARselect(var_32,lag.max = 8,type = "const") 
Info.crit6 = VARselect(var_33,lag.max = 8,type = "const") 
Info.crit7 = VARselect(var_41,lag.max = 8,type = "const") 

Info.crit1
Info.crit2
Info.crit3
Info.crit4
Info.crit5
Info.crit6
Info.crit7

#testing for granger causality among the bivariate VAR models
model21 = VAR(var_21, p = 1, type = "const") #Estimate the firsr VAR model
model22 = VAR(var_22, p = 1, type = "const") #Estimate the second VAR model
model23 = VAR(var_23, p = 1, type = "const") #Estimate the second VAR model

model31 = VAR(var_31, p = 1, type = "const") #Estimate the firsr VAR model
model32 = VAR(var_32, p = 1, type = "const") #Estimate the second VAR model
model33 = VAR(var_33, p = 1, type = "const") #Estimate the second VAR model

model41 = VAR(var_41, p = 1, type = "const") #Estimate the firsr VAR model

summary(model21)
summary(model22)
summary(model23)

summary(model31)
summary(model32)
summary(model33)

summary(model41)

sink("estimates.txt")
        summary(model21)
        summary(model22)
        summary(model23)
        
        summary(model31)
        summary(model32)
        summary(model33)
        
        summary(model41)
sink()
        

 #Test for Granger causality
causality(model21, cause = "emp_df")$Granger
causality(model22, cause = "sp500_rtn")$Granger
causality(model23, cause = "csent_df")$Granger


########################################################################################################
# Part (i)- 1-step, 2-step, 3-step and 4-step ahead out-of-sample recursive forecasting of stock returns
n.end = 336 #Initial sample estimation
t = NROW(pce_df) #Full Sample size
n = t-n.end-2 #Forecast sample

#Set matric storage
# set matrix for storage
pred_var21=matrix(rep(0,3*n),n,3) # storage matrix for the first 2-variable VAR
pred_var22=matrix(rep(0,3*n),n,3)
pred_var23=matrix(rep(0,3*n),n,3)

pred_var31=matrix(rep(0,3*n),n,3)# storage matrix for the 3-variable VAR
pred_var32=matrix(rep(0,3*n),n,3)# storage matrix for the 3-variable VAR
pred_var33=matrix(rep(0,3*n),n,3)# storage matrix for the 3-variable VAR

pred_var41=matrix(rep(0,3*n),n,3)# storage matrix for the 4-variable VAR

pred_ar=matrix(rep(0,3*n),n,3) # storage matrix for the UNIVARIATE MODEL

for(i in 1:n){
  x_ar = var_21[1:n.end+i-1,1]
  
  x_var21 = var_21[1:n.end+i-1,]
  x_var22 = var_22[1:n.end+i-1,] 
  x_var23 = var_23[1:n.end+i-1,]
  
  x_var31 = var_31[1:n.end+i-1,]
  x_var32 = var_32[1:n.end+i-1,]
  x_var33 = var_33[1:n.end+i-1,]
  
  x_var41 = var_41[1:n.end+i-1,]
  
  #AR(1)
  model.ar <- arima(x_ar, order = c(0,0,0), method = "ML")
  pred_ar[i,1:3] <-predict(model.ar, n.ahead=3, se.fit = FALSE)[1:3] 
  
  model.var21 = VAR(x_var21,p = 1, type="const")#2-variable model of pce and emp
  for_var21=predict(model.var21,n.ahead=24,se.fit=FALSE)
  pred_var21[i,1:3]=for_var21$fcst$pce_df[1:3] 
  
  model.var22 = VAR(x_var22, p = 1,type ="const")
  for_var22 = predict(model.var22,n.ahead=3,se.fit=FALSE)
  pred_var22[i,1:3] = for_var22$fcst$pce_df[1:3] 
  
  model.var23 = VAR(x_var23,p = 1,type ="const")
  for_var23=predict(model.var23,n.ahead=3,se.fit=FALSE)
  pred_var23[i,1:3]=for_var23$fcst$pce_df[1:3]
  
  model.var31 = VAR(x_var31,p = 1,type ="const")
  for_var31=predict(model.var31,n.ahead=3,se.fit=FALSE)
  pred_var31[i,1:3]=for_var31$fcst$pce_df[1:3] 
  
  model.var32 = VAR(x_var32,p = 1,type ="const")
  for_var32=predict(model.var32,n.ahead=3,se.fit=FALSE)
  pred_var32[i,1:3]=for_var32$fcst$pce_df[1:3] 
  
  model.var33 = VAR(x_var33,p = 1,type ="const")
  for_var33=predict(model.var33,n.ahead=3,se.fit=FALSE)
  pred_var33[i,1:3]=for_var33$fcst$pce_df[1:3] 
  
  model.var41 = VAR(x_var41,p = 1,type ="const")
  for_var41=predict(model.var41,n.ahead=3,se.fit=FALSE)
  pred_var41[i,1:3]=for_var41$fcst$pce_df[1:3] 
}

# compute prediction errors for VAR
e1_ar = pce_df[(n.end+1):(t-2)]-pred_ar[,1]#1-step ahead forecast error
e2_ar = pce_df[(n.end+2):(t-1)]-pred_ar[,2] #2-step ahead forecast error
e3_ar = pce_df[(n.end+3):(t)]-pred_ar[,3]#1-step ahead forecast error

e1_var21 = pce_df[(n.end+1):(t-2)]-pred_var21[,1]#1-step ahead forecast error
e2_var21 = pce_df[(n.end+2):(t-1)]-pred_var21[,2] #2-step ahead forecast error
e3_var21 = pce_df[(n.end+3):(t)]-pred_var21[,3]#1-step ahead forecast error

e1_var22 = pce_df[(n.end+1):(t-2)] - pred_var22[,1]#1-step ahead forecast error
e2_var22 = pce_df[(n.end+2):(t-1)] - pred_var22[,2] #2-step ahead forecast error
e3_var22 = pce_df[(n.end+3):(t)] - pred_var22[,3]#1-step ahead forecast error

e1_var23 = pce_df[(n.end+1):(t-2)] - pred_var23[,1]#1-step ahead forecast error
e2_var23 = pce_df[(n.end+2):(t-1)] - pred_var23[,2] #2-step ahead forecast error
e3_var23 = pce_df[(n.end+3):(t)] - pred_var23[,3]#1-step ahead forecast error

e1_var31 = pce_df[(n.end+1):(t-2)]-pred_var31[,1]#1-step ahead forecast error
e2_var31 = pce_df[(n.end+2):(t-1)]-pred_var31[,2] #2-step ahead forecast error
e3_var31 = pce_df[(n.end+3):(t)]-pred_var31[,3]#1-step ahead forecast error

e1_var32 = pce_df[(n.end+1):(t-2)]-pred_var32[,1]#1-step ahead forecast error
e2_var32 = pce_df[(n.end+2):(t-1)]-pred_var32[,2] #2-step ahead forecast error
e3_var32 = pce_df[(n.end+3):(t)]-pred_var32[,3]#1-step ahead forecast error

e1_var33 = pce_df[(n.end+1):(t-2)]-pred_var33[,1]#1-step ahead forecast error
e2_var33 = pce_df[(n.end+2):(t-1)]-pred_var33[,2] #2-step ahead forecast error
e3_var33 = pce_df[(n.end+3):(t)]-pred_var33[,3]#1-step ahead forecast error

e1_var41 = pce_df[(n.end+1):(t-2)]-pred_var41[,1]#1-step ahead forecast error
e2_var41 = pce_df[(n.end+2):(t-1)]-pred_var41[,2] #2-step ahead forecast error
e3_var41 = pce_df[(n.end+3):(t)]-pred_var41[,3]#1-step ahead forecast error


rmse1_ar=sqrt(mean(e1_ar^2))
rmse2_ar=sqrt(mean(e2_ar^2))
rmse3_ar=sqrt(mean(e3_ar^2))

rmse1_var21=sqrt(mean(e1_var21^2))
rmse2_var21=sqrt(mean(e2_var21^2))
rmse3_var21=sqrt(mean(e3_var21^2))

rmse1_var22=sqrt(mean(e1_var22^2))
rmse2_var22=sqrt(mean(e2_var22^2))
rmse3_var22=sqrt(mean(e3_var22^2))

rmse1_var23=sqrt(mean(e1_var23^2))
rmse2_var23=sqrt(mean(e2_var23^2))
rmse3_var23=sqrt(mean(e3_var23^2))

rmse1_var31 = sqrt(mean(e1_var31^2))
rmse2_var31 = sqrt(mean(e2_var31^2))
rmse3_var31 = sqrt(mean(e3_var31^2))

rmse1_var32 = sqrt(mean(e1_var32^2))
rmse2_var32 = sqrt(mean(e2_var32^2))
rmse3_var32 = sqrt(mean(e3_var32^2))

rmse1_var33 = sqrt(mean(e1_var33^2))
rmse2_var33 = sqrt(mean(e2_var33^2))
rmse3_var33 = sqrt(mean(e3_var33^2))

rmse1_var41=sqrt(mean(e1_var41^2))
rmse2_var41=sqrt(mean(e2_var41^2))
rmse3_var41=sqrt(mean(e3_var41^2))

#AR RMSE
rmse1_ar; rmse2_ar; rmse3_ar

#RMSE VAR1!- returns and cay
rmse1_var21;rmse2_var21;rmse3_var21
remse1.var21 <- (rmse1_var21/rmse1_ar)
remse2.var21 <- (rmse2_var21/rmse2_ar)
remse3.var21 <- (rmse3_var21/rmse3_ar)
remse1.var21; remse2.var21; remse3.var21

#RMSE VAR2 - returns and ind  
rmse1_var22; rmse2_var22; rmse3_var22
remse1.var22 <- (rmse1_var22/rmse1_ar)
remse2.var22 <- (rmse2_var22/rmse2_ar)
remse3.var22 <- (rmse3_var22/rmse3_ar)
remse1.var22; remse2.var22; remse3.var22

#RMSE VAR2 - returns,cay and ind  
rmse1_var23; rmse2_var23; rmse3_var23
remse1.var23 <- (rmse1_var23/rmse1_ar)
remse2.var23 <- (rmse2_var23/rmse2_ar)
remse3.var23 <- (rmse3_var23/rmse3_ar)
remse1.var23; remse2.var23; remse3.var23

#RMSE VAR2 - returns,cay and ind  
rmse1_var31; rmse2_var31; rmse3_var31
remse1.var31 <- (rmse1_var31/rmse1_ar)
remse2.var31 <- (rmse2_var31/rmse2_ar)
remse3.var31 <- (rmse3_var31/rmse3_ar)
remse1.var31; remse2.var31; remse3.var31

#RMSE VAR2 - returns,cay and ind  
rmse1_var32; rmse2_var32; rmse3_var32
remse1.var32 <- (rmse1_var32/rmse1_ar)
remse2.var32 <- (rmse2_var32/rmse2_ar)
remse3.var32 <- (rmse3_var32/rmse3_ar)
remse1.var32; remse2.var32; remse3.var32

#RMSE VAR2 - returns,cay and ind  
rmse1_var33; rmse2_var33; rmse3_var33
remse1.var33 <- (rmse1_var33/rmse1_ar)
remse2.var33 <- (rmse2_var33/rmse2_ar)
remse3.var33 <- (rmse3_var33/rmse3_ar)
remse1.var33; remse2.var33; remse3.var33

#RMSE VAR2 - returns,cay and ind  
rmse1_var41; rmse2_var41; rmse3_var41
remse1.var41 <- (rmse1_var41/rmse1_ar)
remse2.var41 <- (rmse2_var41/rmse2_ar)
remse3.var41 <- (rmse3_var41/rmse3_ar)
remse1.var41; remse2.var41; remse3.var41

#plotting forecasts against actual values
actual.model <- ts(pce_df[337:359], start = 2017, frequency = 12)
pred.var51 <- ts(pred_var32[,1], start = 2017, frequency = 12)
pred.var52 <- ts(pred_var32[,2], start = 2017, frequency = 12)

plot(actual.model, type = "l", col = "blue", ylab = "Growth rate of consumer spending", main = "Predicted vs Actual Consumption Spending")
lines(pred.var51, col = "red", lty = "dashed")
lines(pred.var52,col = "green", lty = "solid")
legend("bottomleft", legend = c("Actual", "VAR 3 (1-step)", "VAR 3 (2-step)"),
       col=c("blue", "red", "green"), lty=c("solid", "dashed", "solid"), lwd=2:2, cex = 0.8)
abline(h=0)





