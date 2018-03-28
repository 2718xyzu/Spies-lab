
This contains the code for the programs used by the Spies lab


# KERA documentation
 In this folder, you’ll see a new version of the Spies Lab Matlab folder; download it and put it where the current folder of that name is, and delete the old one.  Going inside that folder you’ll see the three wrapper programs; all the supporting functions are in the “functions” folder.  The one we want is, of course, ‘Kera_3’.  When you open that, you should be able to run it using the default settings (which I set to be ‘ebFRET’, one channel, and four states).  Say that you want to select your own data file, and select the SMD file you exported from ebFRET.  Or, you can select to import the savePackage, which you’ll find in the drive folder, and which contains the completed analysis data.  You might as well run it both ways to see how it works, though the end result from both is the same: the data you want appears in your workspace as the variables ‘output’ and ‘stateDwellSummary’.  The only difference is that when you run the analysis on a data file, it will create a savePackage and ask you to save it so you can reopen your session at a later date.  

An explanation of the variables:

All of the analysis you asked me to run for this particular data will be found in the stateDwellSummary variable.  When opened, you’ll see it has four subvariables (called ‘fields’), which contain the times (in seconds) of:
The time before the first event happens (if the trajectory starts at state 1)
The time after the last event happens (if the trajectory ends with state 1)
The times spent at each state organized into four columns (you’ll notice the first row is 1,2,3,4, which are just the labels of the columns).  The state was excluded if it ran into either the beginning or end of a trace.  I guess the times contained in column 1 could be accurately described as the time between events.
The total time of each event (from ground state to ground state).  Again, it was excluded if it overlapped with the edge of the trajectory.  

I would recommend you open the variables in Matlab, but then copy and paste them into Excel (or whatever analysis software you’d like) using the format/organization which makes most sense to you.  Then it should be easy to make histograms, graphs, or whatever it is you typically do with dwell time data.  

The other variable which contains results is the ‘output’ variable, and this is where the exhaustive KERA analysis happens.  Your data is only one channel, but it still went through an analyzed each type of binding event.  The left column shows the event description.  The first row always signifies “any completed event”.  The other rows are more specific:
An underscore indicates the event starts (or ends) at the ground state.
A negative number indicates going down with a certain transition, while positive numbers are up.  
For your data, this is what the numbers mean:
1 = from state 1 to 2 (-1 means from 2 to 1)
2 = from state 2 to 3 (-2 means from 3 to 2)
3 = from state 1 to 3 (-3 from state 3 to 1) (also, notice that this transition is the sum of the first two transitions, both in that 1 + 2 = 3 and 1→2→3 == 1→3)
4 = from state 3 to 4 (-4 means from 4 to 3)
6 = an additive combination of transition 2 and 4, or in other words, a jump from 2→4) .  This transition is only observed once.  

The other columns in the output table are described below:

 
“count” gives the number of events fitting the category
 “meanLength” is the mean length, in ms, of the event described
“eventList” and “timeLengths” are both long lists, with the exact event classification and the length of time taken for each individual event.  However, they are combined, with other useful information, in the final column of the output:
“table”: each cell in this column may be double-clicked to open up a separate table, which contains its own columns. 
In this table, every row is dedicated to a single isolated event.  If there were 200 events in a given “category” (the row in the output table), the event table would have 200 rows.
The first column is the “Events” column, which lists, on each row, the numbers representing the precise sequence of binding which occurred for that event. 
The next column, “Total_Duration”, is the time in seconds which elapsed between the beginning and end of the listed isolated event. 
“Time_Points” lists the position in time of each binding or unbinding.  If there were, as in the example above, 4 binding/unbinding events, four time points would be listed.
“Delta_t” is the time, in ms, between each individual binding/unbinding event and the one after it.   If we continue to use the example above, there would be three numbers in the “Delta_t” list.
“Time_first” is the length of time between the first and second events in the isolated event
“Time_last” is the length of time between the penultimate and last events in the isolated event
“File” lists the filename from which the trace containing this event was originally taken, if the data is from QuB files
The last four columns refer to the gaps between events.  The most interesting one is probably the first row, which is actually equivalent to the first column in the dwellTimes matrix, because both of these measure the time spent at the ground state between successive events.  The only difference is that the stateDwellSummary times are listed in units of ‘frames’ while the times in the output table are listed in units of seconds.  


# Microscope analysis documentation:
