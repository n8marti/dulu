import React, { useEffect, useState } from "react";
import { IEvent, IPeriod } from "../../models/Event";
import DuluAxios from "../../util/DuluAxios";
import { lastYear } from "../../util/Date";
import { Adder, Setter } from "../../models/TypeBucket";
import { Person } from "../../models/Person";
import { ICan } from "../../actions/canActions";
import BasicEventsTable from "../events/BasicEventsTable";
import DomainFilterer from "./DomainFilterer";

interface IProps {
  languageIds: number[];
  events: IEvent[];
  eventsBackTo: number | undefined;
  can: ICan;

  addPeople: Adder<Person>;
  setEventsCan: Setter<ICan>;
  addEventsForLanguage: (e: IEvent[], lid: number, p: IPeriod) => void;
}

export default function DBEventsTable(props: IProps) {
  const [loadingMore, setLoadingMore] = useState(false);
  const [domainFilter, setDomainFilter] = useState("All");

  useEffect(() => {
    if (props.eventsBackTo == undefined && !loadingMore) {
      getEvents(props, setLoadingMore);
    }
  });

  const moreEvents = () => {
    if (!props.eventsBackTo) return;
    getEvents(props, setLoadingMore, props.eventsBackTo - 1);
  };

  const events =
    domainFilter == "All"
      ? props.events
      : props.events.filter(e => e.domain == domainFilter);

  return props.events.length == 0 ? (
    <div />
  ) : (
    <div>
      <DomainFilterer
        domainFilter={domainFilter}
        setDomainFilter={setDomainFilter}
      />
      <BasicEventsTable
        events={events}
        can={props.can}
        noHeader
        moreEventsState={
          loadingMore ? "loading" : props.eventsBackTo == 0 ? "none" : "button"
        }
        moreEvents={moreEvents}
      />
    </div>
  );
}

async function getEvents(
  props: IProps,
  setLoadingMore: (b: boolean) => void,
  year?: number
) {
  setLoadingMore(true);
  const params = year
    ? { start_year: year, end_year: year }
    : { start_year: lastYear() };
  await Promise.all(
    props.languageIds.map(async id => {
      const data = await DuluAxios.get(`/api/languages/${id}/events`, params);
      if (data) {
        props.addPeople(data.people);
        props.setEventsCan(data.can);
        props.addEventsForLanguage(data.events, id, {
          start: data.startYear ? { year: data.startYear } : undefined,
          end: year ? { year: year } : undefined
        });
      }
    })
  );
  setLoadingMore(false);
}