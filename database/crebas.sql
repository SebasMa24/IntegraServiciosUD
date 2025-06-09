/*==============================================================*/
/* DBMS name:      PostgreSQL 9.x                               */
/* Created on:     25/04/2025 4:08:05 p. m.                     */
/*==============================================================*/


drop index RoleUser_FK;

drop index User_PK;

drop table AppUser;

drop index FacultyBuilding_FK;

drop index Building_PK;

drop table Building;

drop index Faculty_PK;

drop table Faculty;

drop index HardwareTypeHW_FK;

drop index Hardware_PK;

drop table Hardware;

drop index HardwareType_PK;

drop table HardwareType;

drop index ManagerHardware_FK;

drop index RequesterHardware_FK;

drop index StoredHWReserved_FK;

drop index ReservedHardware_PK;

drop table ReservedHardware;

drop index ManagerSpace_FK;

drop index RequesterSpace_FK;

drop index SpaceReserved_FK;

drop index ReservedSpace_PK;

drop table ReservedSpace;

drop index Role_PK;

drop table Role;

drop index StateSpace_FK;

drop index SpaceTypeSpace_FK;

drop index BuildingSpace_FK;

drop index Space_PK;

drop table Space;

drop index SpaceType_PK;

drop table SpaceType;

drop index State_PK;

drop table State;

drop index StateStoredHW_FK;

drop index HardwareStoredHW_FK;

drop index WarehouseStoredHW_FK;

drop index StoredHardware_PK;

drop table StoredHardware;

drop index BuildingWarehouse_FK;

drop index Warehouse_PK;

drop table Warehouse;

/*==============================================================*/
/* Table: AppUser                                               */
/*==============================================================*/
create table AppUser (
   email_user           VARCHAR(64)          not null,
   role_user            VARCHAR(32)          not null,
   pass_user            VARCHAR(64)          not null,
   code_user            INT8                 null,
   name_user            VARCHAR(32)          not null,
   phone_user           INT8                 not null,
   address_user         VARCHAR(64)          not null,
   constraint PK_APPUSER primary key (email_user)
);

/*==============================================================*/
/* Index: User_PK                                               */
/*==============================================================*/
create unique index User_PK on AppUser (
email_user
);

/*==============================================================*/
/* Index: RoleUser_FK                                           */
/*==============================================================*/
create  index RoleUser_FK on AppUser (
role_user
);

/*==============================================================*/
/* Table: Building                                              */
/*==============================================================*/
create table Building (
   code_building        INT2                 not null,
   faculty_building     VARCHAR(32)          not null,
   name_building        VARCHAR(64)          not null,
   phone_building       INT8                 not null,
   address_building     VARCHAR(64)          not null,
   email_building       VARCHAR(64)          not null,
   constraint PK_BUILDING primary key (code_building)
);

/*==============================================================*/
/* Index: Building_PK                                           */
/*==============================================================*/
create unique index Building_PK on Building (
code_building
);

/*==============================================================*/
/* Index: FacultyBuilding_FK                                    */
/*==============================================================*/
create  index FacultyBuilding_FK on Building (
faculty_building
);

/*==============================================================*/
/* Table: Faculty                                               */
/*==============================================================*/
create table Faculty (
   name_faculty         VARCHAR(32)          not null,
   desc_faculty         VARCHAR(64)          null,
   constraint PK_FACULTY primary key (name_faculty)
);

/*==============================================================*/
/* Index: Faculty_PK                                            */
/*==============================================================*/
create unique index Faculty_PK on Faculty (
name_faculty
);

/*==============================================================*/
/* Table: Hardware                                              */
/*==============================================================*/
create table Hardware (
   code_hardware        INT8                 not null,
   type_hardware        VARCHAR(32)          not null,
   name_hardware        VARCHAR(32)          not null,
   schedule_hardware    VARCHAR(49)          not null,
   desc_hardware        VARCHAR(64)          null,
   constraint PK_HARDWARE primary key (code_hardware)
);

/*==============================================================*/
/* Index: Hardware_PK                                           */
/*==============================================================*/
create unique index Hardware_PK on Hardware (
code_hardware
);

/*==============================================================*/
/* Index: HardwareTypeHW_FK                                     */
/*==============================================================*/
create  index HardwareTypeHW_FK on Hardware (
type_hardware
);

/*==============================================================*/
/* Table: HardwareType                                          */
/*==============================================================*/
create table HardwareType (
   name_hardwareType    VARCHAR(32)          not null,
   desc_hardwareType    VARCHAR(64)          null,
   constraint PK_HARDWARETYPE primary key (name_hardwareType)
);

/*==============================================================*/
/* Index: HardwareType_PK                                       */
/*==============================================================*/
create unique index HardwareType_PK on HardwareType (
name_hardwareType
);

/*==============================================================*/
/* Table: ReservedHardware                                      */
/*==============================================================*/
create table ReservedHardware (
   code_reshw           INT8                 not null,
   building_reshw       INT2                 not null,
   warehouse_reshw      INT2                 not null,
   storedhw_reshw       INT2                 not null,
   requester_reshw      VARCHAR(64)          not null,
   manager_reshw        VARCHAR(64)          not null,
   start_reshw          TIMESTAMP            not null,
   end_reshw            TIMESTAMP            not null,
   handover_reshw       TIMESTAMP            null,
   return_reshw         TIMESTAMP            null,
   condrate_reshw       INT2                 null,
   serrate_reshw        INT2                 null,
   constraint PK_RESERVEDHARDWARE primary key (code_reshw)
);

/*==============================================================*/
/* Index: ReservedHardware_PK                                   */
/*==============================================================*/
create unique index ReservedHardware_PK on ReservedHardware (
code_reshw
);

/*==============================================================*/
/* Index: StoredHWReserved_FK                                   */
/*==============================================================*/
create  index StoredHWReserved_FK on ReservedHardware (
building_reshw,
warehouse_reshw,
storedhw_reshw
);

/*==============================================================*/
/* Index: RequesterHardware_FK                                  */
/*==============================================================*/
create  index RequesterHardware_FK on ReservedHardware (
requester_reshw
);

/*==============================================================*/
/* Index: ManagerHardware_FK                                    */
/*==============================================================*/
create  index ManagerHardware_FK on ReservedHardware (
manager_reshw
);

/*==============================================================*/
/* Table: ReservedSpace                                         */
/*==============================================================*/
create table ReservedSpace (
   code_resspace        INT8                 not null,
   building_resspace    INT2                 not null,
   space_resspace       INT2                 not null,
   requester_resspace   VARCHAR(64)          not null,
   manager_resspace     VARCHAR(64)          not null,
   start_resspace       TIMESTAMP            not null,
   end_resspace         TIMESTAMP            not null,
   handover_resspace    TIMESTAMP            null,
   return_resspace      TIMESTAMP            null,
   condrate_resspace    INT2                 null,
   serrate_resspace     INT2                 null,
   constraint PK_RESERVEDSPACE primary key (code_resspace)
);

/*==============================================================*/
/* Index: ReservedSpace_PK                                      */
/*==============================================================*/
create unique index ReservedSpace_PK on ReservedSpace (
code_resspace
);

/*==============================================================*/
/* Index: SpaceReserved_FK                                      */
/*==============================================================*/
create  index SpaceReserved_FK on ReservedSpace (
building_resspace,
space_resspace
);

/*==============================================================*/
/* Index: RequesterSpace_FK                                     */
/*==============================================================*/
create  index RequesterSpace_FK on ReservedSpace (
requester_resspace
);

/*==============================================================*/
/* Index: ManagerSpace_FK                                       */
/*==============================================================*/
create  index ManagerSpace_FK on ReservedSpace (
manager_resspace
);

/*==============================================================*/
/* Table: Role                                                  */
/*==============================================================*/
create table Role (
   name_role            VARCHAR(32)          not null,
   desc_role            VARCHAR(64)          null,
   constraint PK_ROLE primary key (name_role)
);

/*==============================================================*/
/* Index: Role_PK                                               */
/*==============================================================*/
create unique index Role_PK on Role (
name_role
);

/*==============================================================*/
/* Table: Space                                                 */
/*==============================================================*/
create table Space (
   building_space       INT2                 not null,
   code_space           INT2                 not null,
   type_space           VARCHAR(32)          not null,
   state_space          VARCHAR(32)          not null,
   name_space           VARCHAR(64)          not null,
   capacity_space       INT2                 not null,
   schedule_space       VARCHAR(49)          not null,
   desc_space           VARCHAR(64)          null,
   constraint PK_SPACE primary key (building_space, code_space)
);

/*==============================================================*/
/* Index: Space_PK                                              */
/*==============================================================*/
create unique index Space_PK on Space (
building_space,
code_space
);

/*==============================================================*/
/* Index: BuildingSpace_FK                                      */
/*==============================================================*/
create  index BuildingSpace_FK on Space (
building_space
);

/*==============================================================*/
/* Index: SpaceTypeSpace_FK                                     */
/*==============================================================*/
create  index SpaceTypeSpace_FK on Space (
type_space
);

/*==============================================================*/
/* Index: StateSpace_FK                                         */
/*==============================================================*/
create  index StateSpace_FK on Space (
state_space
);

/*==============================================================*/
/* Table: SpaceType                                             */
/*==============================================================*/
create table SpaceType (
   name_spaceType       VARCHAR(32)          not null,
   desc_spaceType       VARCHAR(64)          null,
   constraint PK_SPACETYPE primary key (name_spaceType)
);

/*==============================================================*/
/* Index: SpaceType_PK                                          */
/*==============================================================*/
create unique index SpaceType_PK on SpaceType (
name_spaceType
);

/*==============================================================*/
/* Table: State                                                 */
/*==============================================================*/
create table State (
   name_state           VARCHAR(32)          not null,
   desc_state           VARCHAR(64)          null,
   constraint PK_STATE primary key (name_state)
);

/*==============================================================*/
/* Index: State_PK                                              */
/*==============================================================*/
create unique index State_PK on State (
name_state
);

/*==============================================================*/
/* Table: StoredHardware                                        */
/*==============================================================*/
create table StoredHardware (
   building_storedhw    INT2                 not null,
   warehouse_storedhw   INT2                 not null,
   code_storedhw        INT2                 not null,
   hardware_storedhw    INT8                 not null,
   state_storedhw       VARCHAR(32)          not null,
   constraint PK_STOREDHARDWARE primary key (building_storedhw, warehouse_storedhw, code_storedhw)
);

/*==============================================================*/
/* Index: StoredHardware_PK                                     */
/*==============================================================*/
create unique index StoredHardware_PK on StoredHardware (
building_storedhw,
warehouse_storedhw,
code_storedhw
);

/*==============================================================*/
/* Index: WarehouseStoredHW_FK                                  */
/*==============================================================*/
create  index WarehouseStoredHW_FK on StoredHardware (
building_storedhw,
warehouse_storedhw
);

/*==============================================================*/
/* Index: HardwareStoredHW_FK                                   */
/*==============================================================*/
create  index HardwareStoredHW_FK on StoredHardware (
hardware_storedhw
);

/*==============================================================*/
/* Index: StateStoredHW_FK                                      */
/*==============================================================*/
create  index StateStoredHW_FK on StoredHardware (
state_storedhw
);

/*==============================================================*/
/* Table: Warehouse                                             */
/*==============================================================*/
create table Warehouse (
   building_warehouse   INT2                 not null,
   code_warehouse       INT2                 not null,
   constraint PK_WAREHOUSE primary key (building_warehouse, code_warehouse)
);

/*==============================================================*/
/* Index: Warehouse_PK                                          */
/*==============================================================*/
create unique index Warehouse_PK on Warehouse (
building_warehouse,
code_warehouse
);

/*==============================================================*/
/* Index: BuildingWarehouse_FK                                  */
/*==============================================================*/
create  index BuildingWarehouse_FK on Warehouse (
building_warehouse
);

alter table AppUser
   add constraint FK_APPUSER_ROLEUSER_ROLE foreign key (role_user)
      references Role (name_role)
      on delete restrict on update restrict;

alter table Building
   add constraint FK_BUILDING_FACULTYBU_FACULTY foreign key (faculty_building)
      references Faculty (name_faculty)
      on delete restrict on update restrict;

alter table Hardware
   add constraint FK_HARDWARE_HARDWARET_HARDWARE foreign key (type_hardware)
      references HardwareType (name_hardwareType)
      on delete restrict on update restrict;

alter table ReservedHardware
   add constraint FK_RESERVED_MANAGERHA_APPUSER foreign key (manager_reshw)
      references AppUser (email_user)
      on delete restrict on update restrict;

alter table ReservedHardware
   add constraint FK_RESERVED_REQUESTER_APPUSER foreign key (requester_reshw)
      references AppUser (email_user)
      on delete restrict on update restrict;

alter table ReservedHardware
   add constraint FK_RESERVED_STOREDHWR_STOREDHA foreign key (building_reshw, warehouse_reshw, storedhw_reshw)
      references StoredHardware (building_storedhw, warehouse_storedhw, code_storedhw)
      on delete restrict on update restrict;

alter table ReservedSpace
   add constraint FK_RESERVED_MANAGERSP_APPUSER foreign key (manager_resspace)
      references AppUser (email_user)
      on delete restrict on update restrict;

alter table ReservedSpace
   add constraint FK_RESERVED_REQUESTER_APPUSER foreign key (requester_resspace)
      references AppUser (email_user)
      on delete restrict on update restrict;

alter table ReservedSpace
   add constraint FK_RESERVED_SPACERESE_SPACE foreign key (building_resspace, space_resspace)
      references Space (building_space, code_space)
      on delete restrict on update restrict;

alter table Space
   add constraint FK_SPACE_BUILDINGS_BUILDING foreign key (building_space)
      references Building (code_building)
      on delete restrict on update restrict;

alter table Space
   add constraint FK_SPACE_SPACETYPE_SPACETYP foreign key (type_space)
      references SpaceType (name_spaceType)
      on delete restrict on update restrict;

alter table Space
   add constraint FK_SPACE_STATESPAC_STATE foreign key (state_space)
      references State (name_state)
      on delete restrict on update restrict;

alter table StoredHardware
   add constraint FK_STOREDHA_HARDWARES_HARDWARE foreign key (hardware_storedhw)
      references Hardware (code_hardware)
      on delete restrict on update restrict;

alter table StoredHardware
   add constraint FK_STOREDHA_STATESTOR_STATE foreign key (state_storedhw)
      references State (name_state)
      on delete restrict on update restrict;

alter table StoredHardware
   add constraint FK_STOREDHA_WAREHOUSE_WAREHOUS foreign key (building_storedhw, warehouse_storedhw)
      references Warehouse (building_warehouse, code_warehouse)
      on delete restrict on update restrict;

alter table Warehouse
   add constraint FK_WAREHOUS_BUILDINGW_BUILDING foreign key (building_warehouse)
      references Building (code_building)
      on delete restrict on update restrict;

