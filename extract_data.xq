declare function local:getCountry($flight as element(response)) as element(country) {
    let $country := doc("./countries.xml")//response[./code/text() = $flight/flag/text()]/name/text()
    return <country>{$country}</country>
};

declare function local:getAirport($code as xs:string) as xs:string {
    let $airport := doc("./airports.xml")//response[./iata_code/text() = $code]/name/text()
    return if(not(empty($airport))) then $airport[position() = 1] else ''
};


<flights_data>{
    for $flight in doc("./flights.xml")//response
    order by $flight/hex/text() ascending
    return <flight id="{$flight/hex}">
        {local:getCountry($flight)}
        <position>
            {$flight/lat}
            {$flight/lng}
        </position>
        <status>{$flight/status}</status>
        {if (exists($flight/dep_iata)) 
            then 
                let $airport := local:getAirport($flight/dep_iata/text())
                return if (not($airport = '')) then <departure_airport>{$airport}</departure_airport> else ()
            else ()
        }
        {if (exists($flight/arr_iata)) 
            then 
                let $airport := local:getAirport($flight/arr_iata/text())
                return if (not($airport = '')) then <arrival_airport>{$airport}</arrival_airport> else ()
            else ()
        }
    </flight>
}
</flights_data>