<i>Github repository for the final project of the Information Visualization course - Data Science Ms. Program, Unibuc, FMI, year 2021.</i>

<b>Project Authors:</b> Delia Berbec, Alexandra Mocanu - Group 511, Data Science

<b>Project Name:</b> Analysis of consumers shopping habits

<b>Description:</b> Analyzing consumers shopping habits through data exploration and visualization.

- Dataset - 
This is a Brazilian ecommerce public dataset of orders made at Olist Store.
<a href="https://www.kaggle.com/olistbr/brazilian-ecommerce">Dataset Link</a> 

<p>
This project has been heavily inspired by Semiotic (and in particular the Semiotic Docs project, especially for the Dashboard application build and React architecture). 
Links can be found here:

<ul>
<li><a href="https://semiotic.nteract.io/">Semiotic Official Page and Doc</a></li>
<li><a href="https://github.com/nteract/semiotic-docs">Semiotic Docs Github Link</a></li>
<li><a href="https://github.com/nteract/semiotic">Semiotic Github Link</a></li>
</ul>
</p>

<p>
The application uses R, React and Semiotic.
</p>


<h2>Steps for starting the application:</h2>

0. After <code>git clone</code> the project is in a directory called 'DIR'
1. In R Studio, go to the root directory where all the R files are kept (eg. DIR/*.R) and set it as the current session directory.
2. Start the Plumber R API by running <code>source("main.R")</code>
3. Swagger API Documentation will start.
4. Go to ".../DIR/app_semiotic" and run <code>npm start</code> (there should not be any errors if you have npm installed but if there are missing packages please install them with <code>npm install [package]</code>)
5. Semiotic starts!



