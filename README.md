# HINDI
The Harami Candlestick Pattern Indicator

This is a personal project aimed at consolidating big data,processing it and making sense of it. The Harami candlestick pattern is 
considered a reversal pattern and occurs regularly. Some books claim that it heralds a reversal in price movement and this expert 
advisor aims to capitalise on that.

I have written a MQL4 expert advisor which looks at data from 3 candlesticks, decide if a bullish or bearish Harami is in play. The
expert advisor then uses hanlib to place a trade if certain optimised criteria are met. The code can be backtested and paramenters 
optimised using MT4 Strategy Tester.

## How To Use
Place hanlib.mqh in your 'Include' directory (\MQL4\Include) and the mql files in the 'Experts' directory. Fire up the
MetaQuotes Language Editor and compile the EA. Notice that the EAs are currency pairs specific since its parameters have
previously been optimised for certain periods.

Go to MT4 to either run the EA or by backtesting using the Stretegy Tester.
