//+------------------------------------------------------------------+
//|                                                          Sal.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//|                                                        1/30/2024 |
//+------------------------------------------------------------------+
//This is a program to trade in the upward direction only. It works by 
//checking to see if we are currently moving upward, it is in a range of a recent low, and the volume is increasing. 

#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

 


//trade variables
#include <Trade/Trade.mqh> 
CTrade trade;
ulong posTicket;

 
// initializer 
int OnInit(){
  
   

   return(INIT_SUCCEEDED);

}

//ontick function 
void OnTick() {
      
      
      //if we are currently moving up,   && we are in the range of a recentlow && there is no trade open  && the volume is increasing {
      if(isGreen(salTimeFrames[0], 0) && isinOrderBlockRangeGreen(PERIOD_D1) && !PositionSelectByTicket(posTicket) && isVolInc(PERIOD_M30)){
       
            //place a one lot trade and save the ticket 
            trade.Buy(1);
            posTicket= trade.ResultOrder();
      }
      
      //if we have an open order
      if(PositionSelectByTicket(posTicket)){
      
      
         //get the open price of it and the bid      
         double open = PositionGetDouble(POSITION_PRICE_OPEN);
         double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         
         
         //if we are down more than 20% then sell
         if((bid - open)/open *100 <= -20){
         
            trade.PositionClose(posTicket);
            
         //else if we are up by more than 60% sell
         }else if((bid - open)/open *100 >= 60){
         
            trade.PositionClose(posTicket);
         }
      
      }   
      //this ensures a 1-3 risk to reward ratio
          
}




//a global variable for timeframes to trade on 
static ENUM_TIMEFRAMES salTimeFrames[5] = {PERIOD_W1,PERIOD_D1,PERIOD_H4, PERIOD_H1, PERIOD_M30};





//checking if the candle or "move" over a certain period of time is in the positive y direction
bool isGreen(ENUM_TIMEFRAMES timeframe, int shift){
    
      //if open < close its green
      if(iOpen(_Symbol, timeframe , shift)< iClose(_Symbol, timeframe, shift)){
         return true; 
       }else{
         return false; 
        }  
}   


//checking if the candle or "move" over a certain period of time is in the negative y direction
bool isRed(ENUM_TIMEFRAMES timeframe, int shift){
   
      //if open > close its red 
      if(iOpen(_Symbol, timeframe , shift)> iClose(_Symbol, timeframe, shift)){
         return true;
       }else{
         return false; 
        }  
   
}


//function to set the most recent low that we are looking to trade off of
double SetLow(ENUM_TIMEFRAMES Frame, int &currentShiftGreen){
      
       //sets and the timeframe that is used for the parameters for the close and open of each candle
       currentShiftGreen = currentShiftGreen; 
       ENUM_TIMEFRAMES TimeFrame= Frame;
       double OrderBlockLowGreen = 0.0;         
             
       //checks if the close is greater than the open then its a green candle. 
       while(iClose(_Symbol, TimeFrame ,currentShiftGreen)> iOpen(_Symbol, TimeFrame , currentShiftGreen)){
            
            // sets the current and next low so if the next candles close is less than the open then we have the low of the red and green candles
            double CurrentLowGreen= iLow(_Symbol, TimeFrame,currentShiftGreen);
            double NextLowGreen = iLow(_Symbol,TimeFrame ,currentShiftGreen);
                     
                     
             // very crucial for marking the current candle that will go through the while loop. if it is false, then we have the false candle we are on 
             currentShiftGreen++;
                     
             //set of if statements to find which low is lower and sets it to the variable orderblocklowgreen.
                     
             if(NextLowGreen>CurrentLowGreen){
               OrderBlockLowGreen= CurrentLowGreen;
              }else if(CurrentLowGreen> NextLowGreen){
               OrderBlockLowGreen= NextLowGreen;   
               }else{
               OrderBlockLowGreen= NextLowGreen;  
                } 
                        
             
         }
        return OrderBlockLowGreen;
         
               
}   
   
//sets the "high" or the top of the range for the low that we are looking to trade off of
double SetHigh(ENUM_TIMEFRAMES tf, int &currentShiftGreen){
       
       ENUM_TIMEFRAMES timef = tf;
       double OrderblockHighGreen;
       
       //while open > close or while they are red
                          
       while(iOpen(_Symbol, timef, currentShiftGreen )> iClose(_Symbol, timef , currentShiftGreen)){
                                 
               
            //sets the var for the current candle and next candle in case it is false we still have the lows 
            double currentHighGreen= iHigh(_Symbol,timef,currentShiftGreen);
            double nextHighGreen= iHigh(_Symbol, timef, currentShiftGreen );
                     
            //sets the shift to the next candle in case it runs as false then we have the next candle in out index 
            currentShiftGreen ++;
                      
            // set of if statements that gets which high is higher to get the higher ob size                    
            if(currentHighGreen> nextHighGreen){
               OrderblockHighGreen = currentHighGreen;            
             }else if(nextHighGreen> currentHighGreen){
               OrderblockHighGreen= nextHighGreen;
              }else{
               OrderblockHighGreen = nextHighGreen;
               } 
                        
                 
         }
        return OrderblockHighGreen= 0.0;  
          
            
               
}     

//used to check if the pattern we are looking for is correct. we are trying to find the most recent high and 
//compare it to the high of our buy range later on
double setHighScouter(ENUM_TIMEFRAMES timef, int currentShiftGreen, double high){
      
      double highScouter = high;
      int i ; 
      for(i = currentShiftGreen; i >0; i--){
            // if the current high is greater than ob high set that t0 high scputer 
            if(iHigh(_Symbol,timef,i)> high){
                  highScouter= iHigh(_Symbol,timef,i);
              }  
                                           
       }

      return highScouter;            

}



// function to get the recent low 
double getRecentLow(ENUM_TIMEFRAMES timey){
            
      double lowRec= 0.0; 
      int l = 0;  
         
      // uses a while loop to find when the close is greater than the open or each subsequent green candle until its false meaning the current is red
      while(iClose(_Symbol, timey, l )> iOpen(_Symbol, timey, l)){
      
            // declare current and next low at the switch so when its false we have both values
            double curlowRec= iLow(_Symbol, timey,l);
            double nexlowRec = iLow(_Symbol,timey,l+1);
             
             
          
            // sets the low based on which candle is higher  
            if(nexlowRec>curlowRec){
               lowRec = curlowRec;
             }else if(curlowRec> nexlowRec){
               lowRec = nexlowRec;   
              }else{
               lowRec= nexlowRec;  
               } 
              // increase the shift for the next candle to be read               
             l++;   
                        
        // end while loop         
        }
        return lowRec;
                 
}
       






//checks if there is a combination of increasing volume for 3 candles in row
bool isVolInc(ENUM_TIMEFRAMES fr){

       
       long mrv= iVolume(_Symbol, fr, 0);
       long lrv = iVolume(_Symbol,fr,1);
       long slrv = iVolume(_Symbol,fr, 2);
       
       
       //if 0> 1 and theyre green
       if((mrv> lrv) && (isGreen(fr,0) && isGreen(fr,1))){
            return true; 
        }
        
        //if 0> 2 and theyre green
        
       if((mrv> slrv) && (isGreen(fr,0) && isGreen(fr,2))){
            return true; 
        } 
        
       //if 1> 2 and theyre green 
       if((lrv> slrv) && (isGreen(fr,1) && isGreen(fr,2))){
            return true; 
        }
        return false; 

}
  
  
 
//used to check if we are in the range of a recent low
bool isinOrderBlockRangeGreen(ENUM_TIMEFRAMES TF){

     
      int currentShiftGreen = 0;   
      ENUM_TIMEFRAMES Time = TF;
      
      
      
      //use our funtions to set the low and high of our buy range, and also the recent low of the stock to see if its within it.
      //the high scouter function is used to find the most recent high
      double low = SetLow(TF, currentShiftGreen);
      double high =SetHigh(TF, currentShiftGreen);
      double scout = setHighScouter(TF,currentShiftGreen, high);
      double recentlow = getRecentLow(TF);
      
      //if the most recent high found by scout and the high scouter function are equal, we know that there is a problem because the most recent high
      //should always be above the high of the range we are trying to trade off of. The range is always below the most recent high because we are
      //trading in the upwards direction
      //if so we set our new values again
      while (high == scout){
         low = SetLow(TF, currentShiftGreen);
         high = SetHigh(TF,currentShiftGreen);  
         scout= setHighScouter(TF, currentShiftGreen, high);     
       }
      
      
      //if the recent low is less then the high of the range, and also not equal to the bottom of the range,
      //then we are in the zone to be trading.                            
      if(recentlow <= high && recentlow != low){         
          return true;    
       }
         return false; 
        
      
}    
