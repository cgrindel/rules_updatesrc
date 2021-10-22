load(
    "//updatesrc/internal:providers.bzl",
    _UpdateSrcsInfo = "UpdateSrcsInfo",
    _providers = "providers",
)
load(
    "//updatesrc/internal:updatesrc_update.bzl",
    _updatesrc_update = "updatesrc_update",
)
load(
    "//updatesrc/internal:updatesrc_update_all.bzl",
    _updatesrc_update_all = "updatesrc_update_all",
)

# Providers
UpdateSrcsInfo = _UpdateSrcsInfo
providers = _providers

# Rules and Macros
updatesrc_update = _updatesrc_update
updatesrc_update_all = _updatesrc_update_all
