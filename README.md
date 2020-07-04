## Lockdown crime type visuals

This repostory contains the file structure and R script needed to replicate the main visual used in a recent
[article](https://theconversation.com/lockdown-crime-trends-why-antisocial-behaviour-is-up-140479) on crime in Greater London before and after
the COVID19 lockdown. At the time of writing, the script uses crime records from January 2016 to May 2020 (~4.5 million records), so it's 
actually more up-to-date than the article.

![](/img/full_met.png)

The visual is loosely based on those used by [the FT](https://www.ft.com/content/a26fbf7e-48f8-11ea-aeb3-955839e06441) to track COVID19 deaths.
One powerful thing about their visuals is that they effortlessly account for _seasonal_ trends in death rates using previous years as a reference point.
Readers can then intuitively understand what is 'normal', and identify fluctuations which are irregular, and thus likely a result of COVID19.

Similarly, a key characteristic of long-term crime trends is seasonality. To disentangle fluctuations in crime, and pinpoint irregularity resulting
from lockdown measures, we must account for typical monthly fluctuations. This is what I try to do here.

The main challenge in making this is simply downloading and compiling the data. First, follow the instructions below
to download the open crime data from the online web portal. Alternatively, make use of the [API](https://data.police.uk/docs/) and 
[R package](https://github.com/njtierney/ukpolice) to get the equivalent data. Once you have the data saved and named according to the instructions,
the R script should run smoothly to produce the output.

## Open crime data

We get the data through direct download from the [online data portal](https://data.police.uk/data/).
Remembering that we want previous years as our reference point, we are going to select the widest date range possible (at the time of writing),
which is the 36 months spanning from June 2017 to May 2020. As new data is released, this 36-month window will shift. So for example, once June
2020 becomes available, you will only be able to download July 2017 to June 2020. This isn't a huge deal, but remember to take that into account 
when following subsequent steps.

You can select the latest 36-month range using the dropdown menus, and then tick whatever police force(s) we want. In this example, I am going to
use the Metropolitan Police Service, which serve Greater London. So, our selection will look something like this:

![](/img/dates_met.png)

We can then 'Generate file' at the bottom of the page, and on the next page, download a .zip file containing all our crime data for the past 36 months.
Here, I call the .zip file **met_police_june2017_to_june2020** and save it to a local folder named **data**, as per the file structure and folder
in this repository.

Ideally, I'd like to go even further back, before June 2017, to get the best picture possible about seasonal crime trends. We can do this using the 
open [archive](https://data.police.uk/data/archive/) data. This comes in a pretty unfriendly format, because you cannot download by force, and cannot 
select specific time periods. Anyway, you can download all the data prior to June 2017 using a direct download from the 
[archive page](https://data.police.uk/data/archive/) and the following option:

![](/img/archive.png)

Remember that if your 36-month window is more recent than this demonstration, you will need to select a different corresponding archive folder! 
Once downloaded, I name it **archive_to_jun_2017** and save it in the same **data** folder. Note that this might take 5-10 minutes to download, depending on your 
internet connection. Once unzipped, you should have two folders in your **data** folder, named accordingly. Mine look like this:

![](/img/file_names.png)

Once you have the data like this, you can run the script from within the R project, and everything should run smoothly! Please
do [get in touch](https://www.samlangton.info/) if you encounter any issues.