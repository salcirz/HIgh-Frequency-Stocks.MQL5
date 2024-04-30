//+------------------------------------------------------------------+
//|                                                          Sal.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//|                                                        1/30/2024 |
//+------------------------------------------------------------------+

#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

 


//trade variables
#include <Trade/Trade.mqh> 
CTrade trade;
ulong posTicket;

//Lists 



 
// initializer 
int OnInit(){
  
   

   return(INIT_SUCCEEDED);

}

//ontick function 
void OnTick() {
      
      if(isGreen(salTimeFrames[0], 0) && isinOrderBlockRangeGreen(PERIOD_D1) && !PositionSelectByTicket(posTicket) && isVolInc(PERIOD_M30)){
       
            trade.Buy(1);
            posTicket= trade.ResultOrder();
      
      
      }      
          
}



 
static ENUM_TIMEFRAMES salTimeFrames[5] = {PERIOD_W1,PERIOD_D1,PERIOD_H4, PERIOD_H1, PERIOD_M30};





bool isGreen(ENUM_TIMEFRAMES timeframe, int shift){
    
      if(iOpen(_Symbol, timeframe , shift)< iClose(_Symbol, timeframe, shift)){
         return true; 
       }else{
         return false; 
        }  
}   



bool isRed(ENUM_TIMEFRAMES timeframe, int shift){
   
      if(iOpen(_Symbol, timeframe , shift)> iClose(_Symbol, timeframe, shift)){
         return true;
       }else{
         return false; 
        }  
   
}

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
   
double SetHigh(ENUM_TIMEFRAMES tf, int &currentShiftGreen){
       
       ENUM_TIMEFRAMES timef = tf;
       double OrderblockHighGreen;
                          
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
       





bool isVolInc(ENUM_TIMEFRAMES fr){

       
       long mrv= iVolume(_Symbol, fr, 0);
       long lrv = iVolume(_Symbol,fr,1);
       long slrv = iVolume(_Symbol,fr, 2);
       
       if((mrv> lrv) && (isGreen(fr,0) && isGreen(fr,1))){
            return true; 
        }
        
       if((mrv> slrv) && (isGreen(fr,0) && isGreen(fr,2))){
            return true; 
        } 
        
       if((lrv> slrv) && (isGreen(fr,1) && isGreen(fr,2))){
            return true; 
        }
        return false; 

}
   

bool isinOrderBlockRangeGreen(ENUM_TIMEFRAMES TF){

     
      int currentShiftGreen = 0;   
      ENUM_TIMEFRAMES Time = TF;
     
      double low = SetLow(TF, currentShiftGreen);
      double high =SetHigh(TF, currentShiftGreen);
      double scout = setHighScouter(TF,currentShiftGreen, high);
      double recentlow = getRecentLow(TF);
      
      while (high == scout){
         low = SetLow(TF, currentShiftGreen);
         high = SetHigh(TF,currentShiftGreen);  
         scout= setHighScouter(TF, currentShiftGreen, high);     
       }
      
      
      
                                     
      if(recentlow <= high && recentlow != low){         
          return true;    
       }
         return false; 
        
      
}    







              