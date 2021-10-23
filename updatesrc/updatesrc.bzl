load(
    "//updatesrc/internal:providers.bzl",
    _UpdateSrcsInfo = "UpdateSrcsInfo",
)
load(
    "//updatesrc/internal:updatesrc_update.bzl",
    _updatesrc_update = "updatesrc_update",
)
load(
    "//updatesrc/internal:updatesrc_update_all.bzl",
    _updatesrc_update_all = "updatesrc_update_all",
)
load(
    "//updatesrc/internal:update_srcs.bzl",
    _update_srcs = "update_srcs",
)

# Providers
UpdateSrcsInfo = _UpdateSrcsInfo

# Rules and Macros
updatesrc_update = _updatesrc_update
updatesrc_update_all = _updatesrc_update_all

# APIs
update_srcs = _update_srcs
