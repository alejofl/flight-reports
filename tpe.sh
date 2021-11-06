function write_error () {
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root><error><message>$1</message><code>script_error</code></error></root>" > flights.xml
}

function get_data () {
    curl -s https://airlabs.co/api/v9/airports.xml -d api_key="$AIRLABS_API_KEY" > airports.xml
    curl -s https://airlabs.co/api/v9/countries.xml -d api_key="$AIRLABS_API_KEY" > countries.xml
    curl -s https://airlabs.co/api/v9/flights.xml -d api_key="$AIRLABS_API_KEY" > flights.xml
}

function parser_error () {
    echo "\033[0;31mAn error was encountered. Make sure you have Java and Saxon parser installed.\n\033[0mRun '$0 help' for more information"
    exit 2
}

function start_program () {
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root></root>" > airports.xml
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root></root>" > countries.xml
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root></root>" > flights.xml
}

function run () {
    echo "\033[0;33mDownloading data...\033[0m"

    if [ $2 -eq 0 ]
    then
        get_data
        if [ $? -ne 0 ]
        then
            write_error "Data collection failed."
        fi
    fi

    java net.sf.saxon.Query extract_data.xq > flights_data.xml 2> /dev/null
    if [ $? -ne 0 ]
    then
        parser_error
    fi

    java net.sf.saxon.Transform -s:flights_data.xml -xsl:generate_report.xsl qty="$1" -o:report.tex &> /dev/null
    if [ $? -ne 0 ]
    then
        parser_error
    fi

    echo "\033[0;32mReport generated.\033[0m"
    exit 0
}

function help () {
    echo "\033[0;33mFlight Report Generator"
    echo "\033[0mUsage:"
    echo "\033[0;34m     $0 [quantity?] \033[0mDefalult behaviour. Will generate the report. Quantity argument is an optional number greater than zero. If supplied, report will be generated with that amount of flights."
    echo "\033[0;34m     $0 clean \033[0mRemoves all files created by the script, the report included."
    echo "\033[0;34m     $0 help \033[0mThis menu."
    echo ""
    echo "\033[0mImportant Information:"
    echo "• You must have an environment variable called AIRLABS_API_KEY set with your API key for the service.\nUse \033[0;34m\$> export AIRLABS_API_KEY=\"your_key\"\033[0m"
    echo "• In order to obtain the desired result, you must have an internet connection and the following packages installed:"
    echo "     • Java"
    echo "     • CURL"
    echo "     • Saxon Parser"
    echo ""
    echo "By Axel Preiti, Mariano Agopian, Matias Rinaldo & Alejo Flores Lucey"
}

function clean () {
    rm airports.xml &> /dev/null
    rm countries.xml &> /dev/null
    rm flights.xml &> /dev/null
    rm flights_data.xml &> /dev/null
    rm report.tex &> /dev/null
    exit 0
}

function is_num () {
    echo $1 | egrep '^[0-9]+$' > /dev/null
}

if [ $# -gt 1 ]
then
    write_error "Too many arguments."
    run 0 1
elif [ $# -eq 0 ]
then
    run 0 0
else
    if [ $1 = "help" ]
    then
        help
    elif [ $1 = "clean" ]
    then
        clean
    elif is_num $1;
    then
        if [ $1 -gt 0 ]
        then
            run $1 0
        else
            write_error "Argument must be greater than zero."
            run 0 1
        fi
    else
        write_error "Argument supplied is not a number."
        run 0 1
    fi
fi
