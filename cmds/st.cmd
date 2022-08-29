# This should be a test or example startup script

#require urlcam
require adurl
require busy
require nddriverstdarrays
require autosave

errlogInit(20000)

# Autosave settings
epicsEnvSet ("IOCNAME", "ioc02-urlcam")
epicsEnvSet("TOP", "/opt/epics/autosave")
epicsEnvSet("IOCDIR", "urlcam")


# Prefix for all records
epicsEnvSet("PREFIX", "13URL1:")
# The port name for the detector
epicsEnvSet("PORT",   "URL1")
# The queue size for all plugins
epicsEnvSet("QSIZE",  "20")
# The maximim image width; used for row profiles in the NDPluginStats plugin
epicsEnvSet("XSIZE",  "640")
# The maximim image height; used for column profiles in the NDPluginStats plugin
epicsEnvSet("YSIZE",  "360")
# The maximum number of time series points in the NDPluginStats plugin
epicsEnvSet("NCHANS", "2048")
# The maximum number of frames buffered in the NDPluginCircularBuff plugin
epicsEnvSet("CBUFFS", "500")

# Create a URL driver
# URLDriverConfig(const char *portName, int maxBuffers, size_t maxMemory, 
#                 int priority, int stackSize)
URLDriverConfig("$(PORT)", 0, 0)
dbLoadRecords("$(adurl_DB)URLDriver.db","P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")

# Create a standard arrays plugin.
NDStdArraysConfigure("Image1", 3, 0, "$(PORT)", 0)

# This creates a waveform large enough for 2048x2048x3 (e.g. RGB color) arrays.
# This waveform only allows transporting 8-bit images
#dbLoadRecords("$(adcore_DB)NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int8,FTVL=UCHAR,NELEMENTS=12582912")
# This waveform allows transporting 16-bit images
dbLoadRecords("$(adcore_DB)NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int16,FTVL=SHORT,NELEMENTS=12582912")

# Load all other plugins using commonPlugins.cmd

iocshLoad("$(adcore_DIR)/commPlugins.iocsh")

iocshLoad("$(autosave_DIR)/autosave.iocsh", "AS_TOP=$(TOP),IOCNAME=$(IOCNAME)")


asynSetTraceIOMask("$(PORT)",0,2)
#asynSetTraceMask("$(PORT)",0,255)
