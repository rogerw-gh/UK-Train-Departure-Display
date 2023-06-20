import os
import sys
import time
import json

from datetime import timedelta
from timeloop import Timeloop
from datetime import datetime
from PIL import ImageFont, Image
from helpers import get_device
from trains import loadDeparturesForStation, loadDestinationsForDeparture, loadDeparturesForStationRTT, loadDestinationsForDepartureRTT
from luma.core.render import canvas
from luma.core.virtual import viewport, snapshot
from open import isRun

def loadConfig():
    with open('config.json', 'r') as jsonConfig:
        data = json.load(jsonConfig)
        return data

def makeFont(name, size):
    font_path = os.path.abspath(
        os.path.join(
            os.path.dirname(__file__),
            'fonts',
            name
        )
    )
    return ImageFont.truetype(font_path, size)


def renderDestination(departure, font):
    departureTime = departure["aimed_departure_time"]
    destinationName = departure["destination_name"]

    def drawText(draw, width, height):
        train = f"{departureTime}  {destinationName}"
        draw.text((0, 0), text=train, font=font, fill="yellow")

    return drawText


def renderServiceStatus(departure):
    def drawText(draw, width, height):
        train = ""

        if departure["status"] == "CANCELLED" or departure["status"] == "CANCELLED_CALL" or departure["status"] == "CANCELLED_PASS":
            train = "Cancelled"
        else:
            if isinstance(departure["expected_departure_time"], str):
                train = 'Exp '+departure["expected_departure_time"]

            if departure["aimed_departure_time"] == departure["expected_departure_time"]:
                train = "On time"

        w = int(draw.textlength(train, font))
        draw.text((width-w,0), text=train, font=font, fill="yellow")
    return drawText

def renderPlatform(departure):
    def drawText(draw, width, height):
        if departure["mode"] == "bus":
            draw.text((0, 0), text="BUS", font=font, fill="yellow")
        else:
            if isinstance(departure["platform"], str):
                draw.text((0, 0), text="Plat "+departure["platform"], font=font, fill="yellow")
    return drawText

def renderCallingAt(draw, width, height):
    stations = "Calling at:"
    draw.text((0, 0), text=stations, font=font, fill="yellow")


def renderStations(stations):
    def drawText(draw, width, height):
        global stationRenderCount, pauseCount

        if(len(stations) == stationRenderCount - 5):
            stationRenderCount = 0

        draw.text(
            (0, 0), text=stations[stationRenderCount:], width=width, font=font, fill="yellow")

        if stationRenderCount == 0 and pauseCount < 8:
            pauseCount += 1
            stationRenderCount = 0
        else:
            pauseCount = 0
            stationRenderCount += 1

    return drawText

def renderTime(draw, width, height):
    rawTime = datetime.now().time()
    hour, minute, second = str(rawTime).split('.')[0].split(':')

    #w1, h1 = draw.textlength("{}:{}".format(hour, minute), fontBoldLarge)
    #w2, h2 = draw.textlength(":00", fontBoldTall)
    w1 = int(draw.textlength("{}:{}".format(hour, minute), fontBoldLarge))
    w2 = int(draw.textlength(":00", fontBoldTall))
    l1, t1, r1, b1 = draw.textbbox((0,0),"{}:{}".format(hour, minute), fontBoldLarge)
    l2, t2, r2, b2 = draw.textbbox((0,0),":00", fontBoldTall)
    width1, height1 = r1 - l1, b1 - t1
    width2, height2 = r2 - l2, b2 - t2
    width3 = int(widgetWdith/2 - (w1 + w2)/2)


    draw.text((width3, 0), text="{}:{}".format(hour, minute),
              font=fontBoldLarge, fill="yellow")
    draw.text((width3 + width1, 5), text=":{}".format(second),
              font=fontBoldTall, fill="yellow")


def renderWelcomeTo(xOffset):
    def drawText(draw, width, height):
        text = "Welcome to"
        draw.text((int(xOffset), 0), text=text, font=fontBold, fill="yellow")

    return drawText


def renderDepartureStation(departureStation, xOffset):
    def draw(draw, width, height):
        text = departureStation
        draw.text((int(xOffset), 0), text=text, font=fontBold, fill="yellow")

    return draw


def renderDots(draw, width, height):
    text = ".  .  ."
    draw.text((0, 0), text=text, font=fontBold, fill="yellow")


def loadData(apiConfig, journeyConfig):
    runHours = [int(x) for x in apiConfig['operatingHours'].split('-')]
    if isRun(runHours[0], runHours[1]) == False:
        return False, False, journeyConfig['outOfHoursName']

    departures, stationName = loadDeparturesForStation(
        journeyConfig, apiConfig["appId"], apiConfig["apiKey"])

    if len(departures) == 0:
        return False, False, stationName

    firstDepartureDestinations = loadDestinationsForDeparture(
        journeyConfig, departures[0]["service_timetable"]["id"])

    return departures, firstDepartureDestinations, stationName

def loadDataRTT(apiConfig, journeyConfig):
    runHours = [int(x) for x in apiConfig['operatingHours'].split('-')]
    if isRun(runHours[0], runHours[1]) == False:
        return False, False, journeyConfig['outOfHoursName']

    departures, stationName = loadDeparturesForStationRTT(
        journeyConfig, apiConfig["username"], apiConfig["password"])

    if len(departures) == 0:
        return False, False, journeyConfig['outOfHoursName']

    firstDepartureDestinations = loadDestinationsForDepartureRTT(
        journeyConfig, apiConfig["username"], apiConfig["password"], departures[0]["time_table_url"])    

    #return False, False, journeyConfig['outOfHoursName']
    return departures, firstDepartureDestinations, stationName

def drawBlankSignage(device, width, height, departureStation):
    global stationRenderCount, pauseCount

    with canvas(device) as draw:
        welcomeSize = draw.textsize("Welcome to", fontBold)

    with canvas(device) as draw:
        stationSize = draw.textsize(departureStation, fontBold)

    device.clear()

    virtualViewport = viewport(device, width=width, height=height)

    rowOne = snapshot(width, 10, renderWelcomeTo(
        (width - welcomeSize[0]) / 2), interval=10)
    rowTwo = snapshot(width, 10, renderDepartureStation(
        departureStation, (width - stationSize[0]) / 2), interval=10)
    rowThree = snapshot(width, 10, renderDots, interval=10)
    rowTime = snapshot(width, 14, renderTime, interval=1)

    if len(virtualViewport._hotspots) > 0:
        for hotspot, xy in virtualViewport._hotspots:
            virtualViewport.remove_hotspot(hotspot, xy)

    virtualViewport.add_hotspot(rowOne, (0, 0))
    virtualViewport.add_hotspot(rowTwo, (0, 12))
    virtualViewport.add_hotspot(rowThree, (0, 24))
    virtualViewport.add_hotspot(rowTime, (0, 50))

    return virtualViewport


def drawSignage(device, width, height, data):
    global stationRenderCount, pauseCount

    device.clear()

    virtualViewport = viewport(device, width=width, height=height)

    status = "Exp 00:00"
    callingAt = "Calling at:"

    departures, firstDepartureDestinations, departureStation = data

    with canvas(device) as draw:
        l, t, r, b = draw.textbbox((0,0), callingAt, font)
        w, h = r-l, b-t

        width = int(draw.textlength(callingAt, font))

    callingWidth = w
    width = virtualViewport.width

    # First measure the text size
    with canvas(device) as draw:
        ws = int(draw.textlength(status, font))
        pl = int(draw.textlength("Plat 88", font ))

        #pw, ph = draw.textlength("Plat 88", font)

    rowOneA = snapshot(
        width - ws - pl, 10, renderDestination(departures[0], fontBold), interval=10)
    rowOneB = snapshot(ws, 10, renderServiceStatus(
        departures[0]), interval=1)
    rowOneC = snapshot(pl, 10, renderPlatform(departures[0]), interval=10)
    rowTwoA = snapshot(callingWidth, 10, renderCallingAt, interval=100)
    rowTwoB = snapshot(width - callingWidth, 10,
                       renderStations(", ".join(firstDepartureDestinations)), interval=0.1)
    if(len(departures) > 1):
        rowThreeA = snapshot(width - ws - pl, 10, renderDestination(
            departures[1],font), interval=10)
        rowThreeB = snapshot(ws, 10, renderServiceStatus(
            departures[1]), interval=1)
        rowThreeC = snapshot(pl, 10, renderPlatform(departures[1]), interval=10)

    if(len(departures) > 2):
        rowFourA = snapshot(width - ws - pl, 10, renderDestination(
            departures[2],font), interval=10)
        rowFourB = snapshot(ws, 10, renderServiceStatus(
            departures[2]), interval=1)
        rowFourC = snapshot(pl, 10, renderPlatform(departures[2]), interval=10)

    rowTime = snapshot(width, 14, renderTime, interval=1)

    if len(virtualViewport._hotspots) > 0:
        for hotspot, xy in virtualViewport._hotspots:
            virtualViewport.remove_hotspot(hotspot, xy)

    stationRenderCount = 0
    pauseCount = 0

    virtualViewport.add_hotspot(rowOneA, (0, 0))
    virtualViewport.add_hotspot(rowOneB, (width - ws, 0))
    virtualViewport.add_hotspot(rowOneC, (width - ws - pl, 0))
    virtualViewport.add_hotspot(rowTwoA, (0, 12))
    virtualViewport.add_hotspot(rowTwoB, (callingWidth, 12))
    if(len(departures) > 1):
        virtualViewport.add_hotspot(rowThreeA, (0, 24))
        virtualViewport.add_hotspot(rowThreeB, (width - ws, 24))
        virtualViewport.add_hotspot(rowThreeC, (width - ws - pl, 24))
    if(len(departures) > 2):
        virtualViewport.add_hotspot(rowFourA, (0, 36))
        virtualViewport.add_hotspot(rowFourB, (width - ws, 36))
        virtualViewport.add_hotspot(rowFourC, (width - ws - pl, 36))
    virtualViewport.add_hotspot(rowTime, (0, 50))

    return virtualViewport


try:
    config = loadConfig()

    device = get_device()
    font = makeFont("Dot Matrix Regular.ttf", 10)
    fontBold = makeFont("Dot Matrix Bold.ttf", 10)
    fontBoldTall = makeFont("Dot Matrix Bold Tall.ttf", 10)
    fontBoldLarge = makeFont("Dot Matrix Bold.ttf", 20)

    widgetWidth = 256
    widgetHeight = 64

    stationRenderCount = 0
    pauseCount = 0
    loop_count = 0

    if config["apiMethod"] == 'rtt':
        data = loadDataRTT(config["rttApi"], config["journey"])
    else:
        data = loadData(config["transportApi"], config["journey"])      

    if data[0] == False:
        virtual = drawBlankSignage(
            device, width=widgetWidth, height=widgetHeight, departureStation=data[2])
    else:
        virtual = drawSignage(device, width=widgetWidth,
                              height=widgetHeight, data=data)

    timeAtStart = time.time()
    timeNow = time.time()

    while True:
        if(timeNow - timeAtStart >= config["refreshTime"]):
            if config["apiMethod"] == 'rtt':
                data = loadDataRTT(config["rttApi"], config["journey"])
            else:
                data = loadData(config["transportApi"], config["journey"])      
                
            if data[0] == False:
                virtual = drawBlankSignage(
                    device, width=widgetWidth, height=widgetHeight, departureStation=data[2])
            else:
                virtual = drawSignage(device, width=widgetWidth,
                                      height=widgetHeight, data=data)

            timeAtStart = time.time()

        timeNow = time.time()
        virtual.refresh()

except KeyboardInterrupt:
    pass
except ValueError as err:
    print(f"Error: {err}")
except KeyError as err:
    print(f"Error: Please ensure the {err} environment variable is set")
