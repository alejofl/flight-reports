declare function local:getCountry($country as element()) as element(country) {
    let $country := doc("./countries.xml")//response[./code/text() = $country/text()]/name/text()
    return <country>{$country}</country>
};

declare function local:getAirport($code as xs:string, $type as xs:string) as element() {
    let $airport := (doc("./airports.xml")//response[./iata_code/text() = $code])[1]
    return if(exists($airport/name) and exists($airport/country_code)) then element {$type} {
        local:getCountry($airport/country_code),
        $airport/name
    } else <empty_element/>
};


<flights_data>{
    for $flight in doc("./flights.xml")//response[./hex]
    order by $flight/hex/text() ascending
    return <flight id="{$flight/hex}">
        {if (exists($flight/flag)) then local:getCountry($flight/flag) else ()}
        <position>
            {$flight/lat}
            {$flight/lng}
        </position>
        {$flight/status}
        {if (exists($flight/dep_iata)) 
            then 
                let $airport := local:getAirport($flight/dep_iata/text(), 'departure_airport')
                return if (exists($airport/name)) then $airport else ()
            else ()
        }
        {if (exists($flight/arr_iata)) 
            then 
                let $airport := local:getAirport($flight/arr_iata/text(), 'arrival_airport')
                return if (exists($airport/name)) then $airport else ()
            else ()
        }
    </flight>
}
</flights_data>